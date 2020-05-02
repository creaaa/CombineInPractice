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
        HStack(spacing: 16) {
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
                    .padding(4)
                    .border(Color.gray, width: 0.5)
                    .foregroundColor(.white)
                    .keyboardType(.asciiCapable)
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(symbolName: "person.circle",
                  placeholder: "placeholder")
            .background(Color.black)
            .previewLayout(.fixed(width: 414, height: 32))
    }
}
