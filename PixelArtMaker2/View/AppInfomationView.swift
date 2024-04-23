//
//  AppInfomationView.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI

struct AppInfomationView: View {
    
    func makeWebViewLink(url:URL, title:Text) -> some View {
        NavigationLink {
            WebView(url: url, title: title)
                .navigationBarTitle(title)
        } label: {
            title
        }
    }
    
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
    
    var body: some View {
        Section(header:Text("App Infomation")) {
            if let url = Bundle.main.url(forResource: "HTML/term", withExtension: "html") {
                makeWebViewLink(url: url, title: Text("term"))
            }
            
            if let url = Bundle.main.url(forResource: "HTML/privacyPolicy", withExtension: "html") {
                makeWebViewLink(url: url, title: Text("privacyPolicy"))
            }
            
            if let url =  Bundle.main.url(forResource: "HTML/EULA", withExtension: "html") {
                makeWebViewLink(url: url, title: Text("EULA"))
            }
            
            if let url = Bundle.main.url(forResource: "HTML/openSourceLicense", withExtension: "html") {
                makeWebViewLink(url: url, title: Text("openSourceLicense"))
            }
            version
        }
    }
}

#Preview {
    NavigationStack {
        List {
            AppInfomationView()
        }
    }
}
