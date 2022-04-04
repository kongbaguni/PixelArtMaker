//
//  InAppPurchesView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import SwiftUI
import RealmSwift
struct InAppPurchesView: View {
    let inappPurchase = InAppPurchase()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var purches:[InAppPurchaseModel] = []
    @State var discount:[Float] = []
    @State var isLoading = false
    
    var body: some View {
        List {
            Text("subscribe desc1_1")
                .font(.system(size: 15))
            Text("subscribe desc1_2")
                .font(.system(size: 15))
                .foregroundColor(.gray)

            if isLoading {
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                    .frame(height:200)
            }
            
            ForEach(purches, id:\.self) { model in
                Button {
                    inappPurchase.buyProduct(productId: model.id) { isSucess in
                        if isSucess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    let idx = purches.firstIndex(of: model)!
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.title)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                if discount[idx] > 0 {
                                    HStack {
                                    Text(discount[idx].currencyFormatString)
                                    Text("discount")
                                    }
                                }
                            }
                            Spacer()
                            Text(model.price.currencyFormatString)
                                .font(.system(size: 30, weight: .heavy, design: .serif))
                                .foregroundColor(SwiftUI.Color.K_boldText)
                        }
                    }

                }
            }
            Text("subscribe desc2_1")
                .font(.system(size:15))
            Text("subscribe desc2_2")
                .font(.system(size:15))
                .foregroundColor(.gray)
            Text("subscribe desc2_3")
                .font(.system(size:12))
                .foregroundColor(.gray)
            if InAppPurchaseModel.isSubscribe == false {
                Button {
                    inappPurchase.restorePurchases { isSucess in
                        if isSucess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Restore subscribe")
                }
            }
        }
        .animation(.easeInOut, value: isLoading)
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("subscribe"))
        .onAppear {
            isLoading = true
            inappPurchase.getProductInfo {
                isLoading = false
                self.purches = try! Realm().objects(InAppPurchaseModel.self).sorted(byKeyPath: "price", ascending: false).reversed()
                discount.removeAll()
                var dailyPrice:Float = 0
                for model in purches {
                    switch model.id {
                    case "weeklyPlusMode":
                        dailyPrice = model.price / 7
                        discount.append(0)
                        
                    case "monthlyPlusMode":
                        let price = dailyPrice * 30
                        discount.append(price - model.price)
                        
                    case "3monthPlusMode":
                        let price = dailyPrice * 30 * 3
                        discount.append(price - model.price)
                    case "yearlyPlusMode":
                        let price = dailyPrice * 365
                        discount.append(price - model.price)
                    default:
                        break
                    }
                }
                
            }
            
        }
        
    }
    
}

struct InAppPurchesView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchesView()
    }
}
