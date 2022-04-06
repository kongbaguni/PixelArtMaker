//
//  InAppPurchesView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import SwiftUI
import RealmSwift
struct InAppPurchesView: View {
    enum AlertType {
        case 구입복원_구매내역없음
        case 구입복원_구매내역있음
    }
    let inappPurchase = InAppPurchase()

    @State var purches:[InAppPurchaseModel] = []
    @State var discount:[Float] = []
    @State var isLoading = false
    @State var isShowAlert = false
    @State var alertType:AlertType = .구입복원_구매내역없음
    @State var isSubscribe = false
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
                        self.isSubscribe = InAppPurchaseModel.isSubscribe
                    }
                } label: {
                    let idx = purches.firstIndex(of: model)!
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.title)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                if discount[idx] > 0 && model.isExpire {
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
//                                .strikethrough(model.isExpire == false && model.isLastPurchase == true, color: Color.K_boldText)
                        }
                    }

                }//.opacity(model.isExpire == false && model.isLastPurchase ? 0.2 : 1.0)
            }
            Text("subscribe desc2_1")
                .font(.system(size:15))
            Text("subscribe desc2_2")
                .font(.system(size:15))
                .foregroundColor(.gray)
            Text("subscribe desc2_3")
                .font(.system(size:12))
                .foregroundColor(.gray)
            if isSubscribe == false {
                Button {
                    inappPurchase.restorePurchases { isSucess in
                        if isSucess {
                            if InAppPurchaseModel.isSubscribe {
                                alertType = .구입복원_구매내역있음
                                isShowAlert = true
                                return
                            }
                        }
                        alertType = .구입복원_구매내역없음
                        isShowAlert = true
                        self.isSubscribe = InAppPurchaseModel.isSubscribe
                        
                    }
                } label: {
                    Text("Restore subscribe")
                }
            }
        }
        .alert(isPresented: $isShowAlert, content: {
            switch alertType {
            case .구입복원_구매내역없음:
                return Alert(title: Text("empty subscribe title"),
                             message: Text("empty subscribe message"),
                             dismissButton: .cancel(Text("empty subscribe confirm"))
                )
            case .구입복원_구매내역있음:
                return Alert(title: Text("restore subscribe title"),
                             message: Text("restore subscribe message"),
                             dismissButton: .default(Text("restore subscribe confirm")) {
                    
                })

            }
        })
        .animation(.easeInOut, value: isLoading)
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("subscribe"))
        .onAppear {
            isLoading = true
            inappPurchase.getProductInfo {
                isLoading = false
                load()
            }
            
        }
        
    }
    
    private func load() {
        self.isSubscribe = InAppPurchaseModel.isSubscribe
        self.purches = try! Realm().objects(InAppPurchaseModel.self).sorted(byKeyPath: "price", ascending: false).reversed()
        discount.removeAll()
        var dailyPrice:Float = 0
        for model in purches {
            print("구독 : \(model.id) \(model.isExpire)")
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
                
            case "6monthPlusMode":
                let price = dailyPrice * 30 * 6
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

struct InAppPurchesView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchesView()
    }
}