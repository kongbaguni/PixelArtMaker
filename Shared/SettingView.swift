//
//  SettingView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/13.
//

import SwiftUI

struct SettingView: View {
  
    @State var paintRange:String = "0"
    
    var version : some View {
        Group {
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                HStack {
                    Text("version")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text(" : ")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text(appVersion)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                }
            }
        }
    }
    

    func makeTextFiled(label:Text, placeholder:String, value:Binding<String>, keyboardType:UIKeyboardType) -> some View {
        HStack {
            label
            TextField(placeholder, text: value).keyboardType(keyboardType).textFieldStyle(.roundedBorder)
        }
    }
    
    var body: some View {
        List {
            makeTextFiled(label:Text("paint range"), placeholder: "", value: $paintRange, keyboardType: .numberPad)
            version
        }
        .onAppear {
            paintRange = "\(UserDefaults.standard.paintRange)"
        }
        .onDisappear {
            UserDefaults.standard.paintRange = NSString(string: paintRange).integerValue
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
