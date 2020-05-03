//
//  InputView.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/02.
//  Copyright © 2020 crea. All rights reserved.
//

import SwiftUI

struct InputView: View {
    
    struct Input: Identifiable {
        let id = UUID()
        let symbolName: String
        let placeHolder: String
        let textFieldType: TextFieldType
        let checkmarkType: CheckmarkType
    }
    
    let symbolName:  String
    let placeholder: String
    
    @Binding var inputText: String
    
    let checkmarkOpacity: Double

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
                          // フォーカスされたタイミング(画面上で最初に発生したフォーカスは1回、それ以外のフォーカスは2回
                          // returnが押された時
                          // に呼ばれる
                          onEditingChanged: { _ in
                              print("onChanged")
                          },
                          // キーボードのreturnを押されたときのみ呼ばれる。
                          // それ以外はマジで呼ばれない。
                          onCommit: {
                            print("onCommit")
                          }
                )
                    .padding(4)
                    .border(Color.gray, width: 0.5)
                    .foregroundColor(.white)
                    .keyboardType(.asciiCapable)
            }
            
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.green)
                .opacity(checkmarkOpacity)
            
            
            
        }
    }
}

//struct InputView_Previews: PreviewProvider {
//    static var previews: some View {
//        InputView(symbolName: "person.circle",
//                  placeholder: "placeholder",
//                  inputText: <#Binding<String>#>)
//            .background(Color.black)
//            .previewLayout(.fixed(width: 414, height: 32))
//    }
//}
