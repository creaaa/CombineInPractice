//
//  ContentView.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/01.
//  Copyright © 2020 crea. All rights reserved.
//

import SwiftUI
import Combine

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
        case usernameOnCommit(text: String)
        case passwordOnCommit(text: String)
        case passwordAgainOnCommit(text: String)
        case tappedButton
    }
    // Inputs
    private let usernameSubject      = PassthroughSubject<String, Never>()
    private let passwordSubject      = PassthroughSubject<String, Never>()
    private let passwordAgainSubject = PassthroughSubject<String, Never>()
    
    private let tappedButtonSubject = PassthroughSubject<Void, Never>()
    
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    // Outputs
    @Published var isButtonDisabled = true
    
    let inputViewResource = [
        InputViewResource(symbolName:   "person.circle",
                          placeHolder:  "Wizard name",
                          textFieldType: .username
        ),
        InputViewResource(symbolName:   "lock.circle",
                          placeHolder: "Password",
                          textFieldType: .password
        ),
        InputViewResource(symbolName:   "lock.circle",
                          placeHolder: "Repeat password",
                          textFieldType: .passwordAgain
        )
    ]
    
    var cancellables: [AnyCancellable] = []
    
    init() {
        bind()
    }
    
    private func bind() {
        let validatedUsername: AnyPublisher<String?, Never> = $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
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
        
        var validatedCredentials: AnyPublisher<(String, String)?, Never> {
            validatedUsername
                .combineLatest(validatedPassword) { username, password in
                    guard let uname = username, let pwd = password else { return nil }
                    return (uname, pwd)
                }
                .eraseToAnyPublisher()
        }
        
        validatedCredentials
            .print()
            .map { credential in
                credential != nil ? false : true
            }
            .assign(to: \.isButtonDisabled, on: self)
            .store(in: &cancellables)
    }
    
    private func usernameAvailable(_ username: String, completion: (Bool) -> Void) {
        if username != "username" {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func apply(inputs: Inputs) {
        switch inputs {
            case let .usernameOnCommit(text):
                self.usernameSubject.send(text)
            case let .passwordOnCommit(text):
                self.passwordSubject.send(text)
            case let .passwordAgainOnCommit(text):
                self.passwordAgainSubject.send(text)
            case .tappedButton:
                self.tappedButtonSubject.send(())
        }
    }
}

struct WizardSchoolSignupView: View {
    
    @ObservedObject private var viewModel = WizardSchoolSignupViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack(spacing: 15) {
                        ForEach(viewModel.inputViewResource) { r in
                            InputView(symbolName: r.symbolName,
                                      placeholder: r.placeHolder,
                                      inputText: self.textType(textFieldType: r.textFieldType))
                                .padding(.leading, 25)
                                .padding(.trailing, 25)
                        }
                    }
                    
                    Button(
                        action: {
                            self.viewModel.apply(inputs: .tappedButton)
                        },
                        label: {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .padding(EdgeInsets(top: 15, leading: 100, bottom: 15, trailing: 100))
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    )
                    .disabled(viewModel.isButtonDisabled)
                    .offset(y: 30)
                }
            }
            .navigationBarTitle("Wizard School Signup", displayMode: .inline)
        }
        .navigationBarColor(.black)
    }
    
    private func textType(textFieldType: WizardSchoolSignupViewModel.TextFieldType) -> Binding<String> {
        switch textFieldType {
        case .username:
            return $viewModel.username
        case .password:
            return $viewModel.password
        case .passwordAgain:
            return $viewModel.passwordAgain
        }
    }
    
     
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WizardSchoolSignupView()
    }
}
