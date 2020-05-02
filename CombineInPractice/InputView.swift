//
//  InputView.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/02.
//  Copyright © 2020 crea. All rights reserved.
//

import SwiftUI

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
                    Text(placeholder)
                        .foregroundColor(
                            Color(UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1))
                        )
                }
                TextField(placeholder,
                          text: $inputText,
                          onEditingChanged: { _ in
                            print("a")
                          },
                          onCommit: {
                            print("b")
                          }
                )
                    .foregroundColor(.white)
                    .keyboardType(.asciiCapable)
            }
            
        }
    }
}
