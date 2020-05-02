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

struct InputView: View {
    
    let symbolName:  String
    let placeholder: String
    @State var inputText = ""

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: symbolName)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                if inputText.isEmpty {
                    Text("Placeholder")
                        .foregroundColor(
                            Color(UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1)
                            )
                        )
                }
                TextField(placeholder,
                          text: $inputText,
                          onEditingChanged: { _ in
                            print("s")
                          },
                          onCommit: {
                            print("s")
                          }
                )
                    .foregroundColor(.white)
                    .keyboardType(.asciiCapable)
            }
            
        }
    }
}

struct ContentView: View {
    
    @ObservedObject private var viewModel = WizardSchoolSignupViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ForEach(viewModel.inputViewResource) { r in
                        InputView(symbolName: r.symbolName,
                                  placeholder: r.placeHolder)
                            .padding(.leading, 30)
                            .padding(.top, 10)
                            .padding(.bottom, 2)
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
        ContentView()
    }
}
