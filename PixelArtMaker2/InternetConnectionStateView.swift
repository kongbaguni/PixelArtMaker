//
//  InternetConnectionStateView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2023/07/21.
//

import SwiftUI
import Reachability

struct InternetConnectionStateView: View {
    
    @State var reachability:Reachability? = nil
    @Binding var isConnected:Bool
    var body: some View {
        VStack {
            Text(isConnected
                 ? "Internet Connected"
                 : "Intwernet Disconnected")
            .padding(10)
            .background(Color.k_normalText)
            .cornerRadius(10)
            .foregroundColor(.k_background)
        }.onAppear {
            checkInternetConnection()
        }.onDisappear {
            self.reachability?.stopNotifier()
        }
    }
    
    func checkInternetConnection() {
        do {
            let reachability = try Reachability()
            reachability.whenReachable = { reachability in
                self.isConnected = true
            }
            reachability.whenUnreachable = { _ in
                self.isConnected = false
            }
            try reachability.startNotifier()
            self.reachability = reachability
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct InternetConnectionStateView_Previews: PreviewProvider {
    static var previews: some View {
        let value1 = Binding<Bool>(get:{return false},set:{ _ in})
        InternetConnectionStateView(isConnected: value1)
        
        let value2 = Binding<Bool>(get:{return true},set:{ _ in})
        InternetConnectionStateView(isConnected: value2)

    }
}
