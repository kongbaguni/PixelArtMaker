//
//  SideMenu.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI
import ActivityView
import Network

struct SideMenuView: View {
    let googleAd = GoogleAd()
    
    @Binding var isShowMenu:Bool
    @Binding var isShowSigninView:Bool
    @Binding var alertType:PixelDrawView.AlertType
    @Binding var isShowAlert:Bool
    @Binding var isShowProfileView:Bool
    @Binding var isShowInAppPurches:Bool
    @Binding var isShowSaveView:Bool
    @Binding var isShowLoadView:Bool
    @Binding var isShowShareListView:Bool
    @Binding var isShowTimelineReply:Bool
    @Binding var isShowSettingView:Bool
    @State var isSignIn = false
    @State var isInternetConnected = false
    @State var activityItem:ActivityItem? = nil
    let monitor = NWPathMonitor()
    @State var isUseAd = InAppPurchaseModel.isSubscribe == false
    
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false

    
    func makeBtn(image:Image, text:Text, action:@escaping()->Void)-> some View {
        Button {
            action()
        } label : {
            SidebarMenuView(image: image, text: text)
        }
    }
    
    var signInBtnView : some View {
        makeBtn(image: Image(systemName: "iphone.and.arrow.forward"), text: .menu_signin_title) {
            isShowSigninView = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var clearBtnView : some View {
        makeBtn(image: Image(systemName: "clear"), text: .clear_all_button_title)  {
            if isSignIn {
                if InAppPurchaseModel.isSubscribe == false {
                    if MyStageModel.stageCount >= Consts.free_myGalleryLimit {
                        alertType = .limitOverClear
                        isShowAlert = true
                        return
                    }
                }
            }
            
            alertType = .clear
            isShowAlert = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
                    
    var profileBtnView : some View {
        makeBtn(image: Image(systemName: "person"), text: Text("profile")) {
            isShowProfileView = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var subscribeBtnView : some View {
        makeBtn(image: Image(systemName: "plus"), text: Text("subscribe")) {
            isShowInAppPurches = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    var saveBtnView : some View {
        makeBtn(image: Image(systemName: "icloud.and.arrow.up"), text: .menu_save_title) {
            isShowSaveView = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    var loadBtnView : some View {
        makeBtn(image: Image(systemName: "icloud.and.arrow.down"), text: .menu_load_title) {
            isShowLoadView = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var shareBtnView : some View {
        makeBtn(image: Image(systemName: "text.below.photo"), text: .menu_public_load_title) {
            isShowShareListView = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var timelineReplyBtnView : some View {
        makeBtn(image: Image(systemName: "text.bubble"), text: Text("timeline")) {
            isShowTimelineReply = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var deleteBtnView : some View {
        makeBtn(image: Image(systemName: "trash"), text: .menu_delete_title) {
            alertType = .delete
            isShowAlert = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)
    }
    
    var signoutBtnView : some View {
        makeBtn(image: Image(systemName: "rectangle.portrait.and.arrow.right"), text: .menu_signout_title) {
            alertType = .signout
            isShowAlert = true
        }
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)

    }
        
    var settingView : some View {
        makeBtn(image: Image(systemName:"gear"), text: Text("Setting")) {
            isShowSettingView = true
        }
    }
    
    var shareBtnViewAtSignOut : some View {
        makeBtn(image: Image(systemName: "square.and.arrow.up"), text: Text("share")) {
            googleAd.showAd { error in
                self.error = error
                if error == nil  {
                    if let image = StageManager.shared.stage?.makeImageDataValue(size: StageManager.shared.canvasSize) {
//                        share(items: [image])
                        activityItem = .init(itemsArray: [image])
                    }
                }
            }
        }
        .activitySheet($activityItem)
        .disabled(isInternetConnected == false)
        .opacity(isInternetConnected ? 1.0 : 0.5)

    }
    
    var body: some View {
        List {
            if !isSignIn {
                signInBtnView
                Spacer()
            }
            if isSignIn {
                profileBtnView
                subscribeBtnView
                Spacer()
                saveBtnView
                loadBtnView
                Spacer()
                shareBtnView
                timelineReplyBtnView
                Spacer()
                if StageManager.shared.stage?.documentId != nil {
                    deleteBtnView
                }
            }
            if !isSignIn {
                shareBtnViewAtSignOut
            }
            clearBtnView
            Spacer()
            settingView
            if isSignIn {
                signoutBtnView
            }
            if isUseAd {
                BannerAdView(sizeType: .GADAdSizeSkyscraper)
                    .padding(.top,20).padding(.bottom,20)
            }

        }
        .background(.gray)
        .listStyle(SidebarListStyle())
        .frame(width: 200)
        .transition(.move(edge: .leading))
        .zIndex(2)
        .onAppear {
            isSignIn = AuthManager.shared.isSignined
            isUseAd = InAppPurchaseModel.isSubscribe == false 
            NotificationCenter.default.addObserver(forName: .authDidSucessed, object: nil, queue: nil) { _ in
                isSignIn = true
            }
            NotificationCenter.default.addObserver(forName: .signoutDidSucessed, object: nil, queue: nil) { _ in
                isSignIn = false
                withAnimation(.easeInOut) {
                    isShowMenu = false
                }
            }
            monitor.pathUpdateHandler = { path in
                isInternetConnected = path.status == .satisfied
            }
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        }
        .onDisappear {
            monitor.cancel()
        }
        .alert(isPresented: $isAlert, content: {
            .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        })
       

    }
}

