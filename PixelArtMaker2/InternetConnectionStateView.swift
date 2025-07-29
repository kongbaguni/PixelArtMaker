//
//  InternetConnectionStateView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2023/07/21.
//

import SwiftUI
import Network

struct InternetConnectionStateView: View {
    
    let monitor = NWPathMonitor()
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
        }
        .onDisappear {
            monitor.cancel()
        }
    }
    
    func checkInternetConnection() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied            
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
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
