//
//  SettingView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/13.
//

import SwiftUI
import ImagePickerView
import PhotosUI

fileprivate let transparancyStyleColors:[(a:UIColor,b:UIColor)] = [
    (a:UIColor(white: 1,alpha: 1), b:UIColor(white: 0.8, alpha: 1)),
    (a:UIColor(white: 0.9,alpha: 1), b:UIColor(white: 0.7, alpha: 1)),
    (a:UIColor(white: 0.8,alpha: 1), b:UIColor(white: 0.6, alpha: 1)),
    (a:UIColor(white: 0.6,alpha: 1), b:UIColor(white: 0.3, alpha: 1)),
    (a:UIColor(white: 0.3,alpha: 1), b:UIColor(white: 0.1, alpha: 1)),
    (a:.init(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0), b: .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)),
    (a:.init(red: 0.4, green: 0.3, blue: 0.5, alpha: 1.0), b: .init(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0)),
    (a:.init(red: 0.4, green: 0.5, blue: 0.3, alpha: 1.0), b: .init(red: 0.2, green: 0.3, blue: 0.1, alpha: 1.0)),
]

fileprivate var transparancyImages:[Image] {
    var timages:[Image] = []
    for color in transparancyStyleColors {
        if let image = UIImage(pixelSize: (width: 5, height: 5), backgroundColor: .clear, size: CGSize(width: 200, height: 200), transparencyColor: color) {
            timages.append(Image(uiImage: image))
        }
    }
    return timages
}

struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var paintRange:String = "0"
    @State var transparancySelection:Int? = nil

    @State var isShowSheets = false
    @State var photoPickerImages:[UIImage] = []
    @Binding var tracingImageData:PixelDrawView.TracingImageData?
    
    
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
    
    func makeWebViewLink(url:URL, title:Text) -> some View {
        NavigationLink {
            WebView(url: url)
                .navigationBarTitle(title)
        } label: {
            title
        }
    }
    
    
    func makeTransparencyStylePicker() -> some View {
        VStack {
            HStack {
                Text("transparancy style").font(.headline)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<transparancyImages.count, id:\.self) { idx in
                        Button {
                            transparancySelection = idx
                        } label : {
                            VStack {
                                transparancyImages[idx]
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                                Text(" ")
                                    .frame(width: 20, height: 5, alignment: .center)
                                    .padding(5)
                                    .background(transparancySelection == idx ? Color.K_boldText : .clear)
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func makeTracingImageSelecter() -> some View {
        VStack {
            HStack {
                Text("tracing image setting").font(.headline)
                Spacer()
            }
            HStack {
                Button {
                    if photoPickerImages.count > 0 {
                        photoPickerImages = []
                    } else {
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                            switch status {
                            case .authorized:
                                isShowSheets = true
                            default:
                                break
                            }
                        }
                    }
                    
                } label : {
                    if let img = photoPickerImages.first {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    else {
                        Text("tracing image select").font(.subheadline).foregroundColor(.gray)
                    }
                }
                Spacer()

            }
        }
    }
    
    var body: some View {
        List {
            Section(header:Text("Setting")) {
                makeTextFiled(label:Text("paint range"), placeholder: "", value: $paintRange, keyboardType: .numberPad)
                
                makeTransparencyStylePicker()
                
                makeTracingImageSelecter()
            }
            
            Section(header:Text("App Infomation")) {
                if let url = Bundle.main.url(forResource: "HTML/term", withExtension: "html") {
                    makeWebViewLink(url: url, title: Text("term"))
                }
                
                if let url = Bundle.main.url(forResource: "HTML/privacyPolicy", withExtension: "html") {
                    makeWebViewLink(url: url, title: Text("privacyPolicy"))
                }
                
                if let url = Bundle.main.url(forResource: "HTML/openSourceLicense", withExtension: "html") {
                    makeWebViewLink(url: url, title: Text("openSourceLicense"))
                }
                version
            }

        }
        .toolbar {
            Button {
                UserDefaults.standard.paintRange = NSString(string: paintRange).integerValue

                UserDefaults.standard.transparencyColor = transparancyStyleColors[transparancySelection ?? 0]
                UserDefaults.standard.transparencyIndex = transparancySelection ?? 0
                if let image = photoPickerImages.first {
                    tracingImageData = .init(image: image, opacity: 0.5, blendMode: .normal)
                } else {
                    tracingImageData = nil
                }
                
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("save")
            }
            
        }
        .navigationTitle(Text("Setting"))
        .onAppear {
            paintRange = "\(UserDefaults.standard.paintRange)"
            transparancySelection = UserDefaults.standard.transparencyIndex
            if let data = tracingImageData {
                photoPickerImages.append(data.image)
            }
        }
        .sheet(isPresented: $isShowSheets) {
            PhotoPicker(images: $photoPickerImages)
        }
    }
}

