//
//  InAppPurchesView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import SwiftUI
import RealmSwift
struct InAppPurchesView: View {
    let inapp = InAppPurchase()
    @State var purches:[InAppPurchaseModel] = []
    var body: some View {
        List {
            ForEach(purches, id:\.self) { model in
                Text(model.title)
            }
        }
        .onAppear {
            inapp.getProductInfo {
                self.purches = try! Realm().objects(InAppPurchaseModel.self).sorted(byKeyPath: "price").reversed()
            }
        }
    }
    
}

struct InAppPurchesView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchesView()
    }
}
