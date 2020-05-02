//
//  File.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/02.
//  Copyright © 2020 crea. All rights reserved.
//

import Combine
import Foundation

final class WizardSchoolSignupViewModel: ObservableObject {
    
    enum TextFieldType {
        case username, password, passwordAgain
    }
    
    struct InputViewResource: Identifiable {
        let id = UUID()
        let symbolName: String
        let placeHolder: String
        let textFieldType: TextFieldType
    }
    
    enum Inputs {
        case tappedButton
    }
    
    enum AlertType {
        case signupSuccess
        case signupFailure
    }
    
    // Inputs
    private let apiService: APIServiceType

    @Published var username        = ""
    @Published var password        = ""
    @Published var passwordAgain   = ""
    
    @Published var shouldShowAlert = false
    @Published var alertType: AlertType?
    
    private let tappedButtonSubject = PassthroughSubject<Void, Never>()
    private let errorSubject        = PassthroughSubject<APIServiceError, Never>()
    

    // Outputs
    @Published var isButtonDisabled = true
    @Published var buttonOpacity    = 0.2
    
    let inputViewResource = [
        InputViewResource(symbolName:    "person.circle",
                          placeHolder:   "Wizard name",
                          textFieldType: .username
        ),
        InputViewResource(symbolName:    "lock.circle",
                          placeHolder:   "Password",
                          textFieldType: .password
        ),
        InputViewResource(symbolName:   "lock.circle",
                          placeHolder: "Repeat password",
                          textFieldType: .passwordAgain
        )
    ]
    
    var cancellables: [AnyCancellable] = []
    
    init(service: APIServiceType) {
        self.apiService = service
        bind()
    }
    
    private func bind() {
        let validatedUsername: AnyPublisher<String?, Never> = $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0 != "" }
            .flatMap { username in
                return Future { promise in
                    self.usernameAvailable(username) { available in
                        promise(.success(available ? username : nil))
                    }
                }
            }
            .eraseToAnyPublisher()
        let validatedPassword: AnyPublisher<String?, Never> = $password
            // combineLatest、別に2個目のtextfieldに1個も値が流れてない時点でも、1個目のtextfieldの値が変わるたびに値が流れる
            .combineLatest($passwordAgain) { password, passwordAgain in
                guard
                    password == passwordAgain,
                    password.count >= 8,
                    password != "password"
                else
                    { return nil }
                return password
            }
            .eraseToAnyPublisher()
        let validatedCredentials: AnyPublisher<(String, String)?, Never> = validatedUsername
                .combineLatest(validatedPassword) { username, password in
                    guard let uname = username, let pwd = password else { return nil }
                    return (uname, pwd)
                }
                .eraseToAnyPublisher()
        validatedCredentials
            .map { credential in
                credential != nil ? true : false
            }
            .sink { valid in
                if valid {
                    self.isButtonDisabled = false
                    self.buttonOpacity    = 1.0
                } else {
                    self.isButtonDisabled = true
                    self.buttonOpacity    = 0.2
                }
            }
            .store(in: &cancellables)
        tappedButtonSubject
            .sink {
                let no = [0, 1].randomElement()!
                if no % 2 == 0 {
                    self.alertType = .signupSuccess
                } else {
                    self.alertType = .signupFailure
                }
                self.shouldShowAlert = true
            }
            .store(in: &cancellables)
    }
    
    private func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
        apiService.request(with: UsernameValidationRequest(username: username))
            .sink(
                receiveCompletion: { error in
                    if case let .failure(e) = error {
                        self.errorSubject.send(e)
                    }
                },
                receiveValue: { result in
                    completion(result.available)
                }
            )
            .store(in: &cancellables)
    }
    
    func apply(inputs: Inputs) {
        switch inputs {
            case .tappedButton:
                self.tappedButtonSubject.send(())
        }
    }
    
}
