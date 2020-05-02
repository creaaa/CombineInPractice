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
    
    struct InputViewResource: Identifiable {
        let id = UUID()
        let symbolName: String
        let placeHolder: String
    }
    
    enum Inputs {
        case tappedButton
    }
    
    private let tappedButtonSubject = PassthroughSubject<Void, Never>()
    
    let inputViewResource = [
        InputViewResource(symbolName:   "person.circle",
                          placeHolder:  "Wizard name"),
        InputViewResource(symbolName:   "lock.circle",
                          placeHolder: "Password"),
        InputViewResource(symbolName:   "lock.circle",
                          placeHolder: "Repeat password")
    ]
    
    func apply(inputs: Inputs) {
        switch inputs {
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
                    VStack(spacing: 10) {
                        ForEach(viewModel.inputViewResource) { r in
                            InputView(symbolName: r.symbolName,
                                      placeholder: r.placeHolder)
                                .padding(.leading, 30)
                        }
                    }
                    
                    Button(
                        action: {
                            self.viewModel.apply(inputs: .tappedButton)
                        },
                        label: {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    )
                    .offset(y: 30)
                }
            }
            .navigationBarTitle("Wizard School Signup", displayMode: .inline)
        }
        .navigationBarColor(.black)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WizardSchoolSignupView()
    }
}
