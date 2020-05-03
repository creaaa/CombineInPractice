//
//  ContentView.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/01.
//  Copyright © 2020 crea. All rights reserved.
//

import SwiftUI
import Combine

struct WizardSchoolSignupView: View {
    
    @ObservedObject private var viewModel: WizardSchoolSignupViewModel
    
    init(viewModel: WizardSchoolSignupViewModel) {
        self.viewModel = viewModel
    }
    
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
                                      inputText: self.textType(textFieldType: r.textFieldType),
                                      checkmarkOpacity: self.checkmarkOpacity(checkmarkType: r.checkmarkType))
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
                                .opacity(viewModel.buttonOpacity)
                        }
                    )
                    .disabled(viewModel.isButtonDisabled)
                    .offset(y: 30)
                    // .alert() は複数チェインできず、最後の.alert()だけが有効
                    .alert(isPresented: $viewModel.shouldShowAlert) {
                        alert()
                    }
                }
            }
            .navigationBarTitle("Wizard School Signup", displayMode: .inline)
        }
        .navigationBarColor(.black)
    }
    
    private func textType(textFieldType: TextFieldType) -> Binding<String> {
        switch textFieldType {
            case .username:
                return $viewModel.username
            case .password:
                return $viewModel.password
            case .passwordAgain:
                return $viewModel.passwordAgain
        }
    }
    
    private func checkmarkOpacity(checkmarkType: CheckmarkType) -> Double {
        switch checkmarkType {
            case .username:
                return viewModel.usernameCheckmarkOpacity
            case .password:
                return viewModel.passwordCheckmarkOpacity
            case .passwordAgain:
                return viewModel.passwordAgainCheckmarkOpacity
        }
    }
    
    private func alert() -> Alert {
        guard let alertType = viewModel.alertType else { fatalError() }
        switch alertType {
            case .signupSuccess:
                return Alert(title: Text("Signup Success!"))
            case .signupFailure:
                return Alert(title: Text("Signup Failure!"))
        }
    }
     
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WizardSchoolSignupView(viewModel: WizardSchoolSignupViewModel(service: APIService()))
    }
}
