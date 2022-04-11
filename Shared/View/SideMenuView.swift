//
//  SideMenu.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowSigninView:Bool
    @Binding var alertType:PixelDrawView.AlertType
    @Binding var isShowAlert:Bool
    @Binding var isShowProfileView:Bool
    @Binding var isShowInAppPurches:Bool
    @Binding var isShowSaveView:Bool
    @Binding var isShowLoadView:Bool
    @Binding var isShowShareListView:Bool
    
    
    var body: some View {
        List {
            if AuthManager.shared.isSignined == false {
                Button {
                    isShowSigninView = true
                } label : {
                    SidebarMenuView(image: Image(systemName: "iphone.and.arrow.forward"), text: .menu_signin_title)
                }
                
                Button {
                    alertType = .clear
                    isShowAlert = true
                } label: {
                    SidebarMenuView(image: Image(systemName: "clear"), text: .clear_all_button_title)
                }
                
                Spacer()
            } else {
                Group {
                    Button {
                        isShowProfileView = true
                    } label : {
                        SidebarMenuView(image: Image(systemName: "person"), text: Text("profile"))
                    }
                    
                    
                    Button {
                        isShowInAppPurches = true
                    } label : {
                        SidebarMenuView(image: Image(systemName: "plus"), text: Text("subscribe"))
                    }
                    Spacer()
                }
                
                Group {
                    Button {
                        isShowSaveView = true
                    } label : {
                        SidebarMenuView(image: Image(systemName: "icloud.and.arrow.up"), text: .menu_save_title)
                    }
                    
                    
                    Button {
                        isShowLoadView = true
                    } label: {
                        SidebarMenuView(image: Image(systemName: "icloud.and.arrow.down"), text: .menu_load_title)
                    }
                    
                    Button {
                        isShowShareListView = true
                    } label: {
                        SidebarMenuView(image: Image(systemName: "icloud.square"), text: .menu_public_load_title)
                    }
                    Spacer()
                }
                
                Group {
                    if StageManager.shared.stage?.documentId != nil {
                        Button {
                            alertType = .delete
                            isShowAlert = true
                        } label: {
                            SidebarMenuView(image: Image(systemName: "trash"), text: .menu_delete_title)
                        }
                    }
                    
                    Button {
                        alertType = .clear
                        isShowAlert = true
                    } label: {
                        SidebarMenuView(image: Image(systemName: "clear"), text: .clear_all_button_title)
                    }
                    Spacer()
                }
                
                Button {
                    AuthManager.shared.signout()
                } label : {
                    SidebarMenuView(image: Image(systemName: "rectangle.portrait.and.arrow.right"), text: .menu_signout_title)
                }
                
            }
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                HStack {
                    Text("version : ")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text(appVersion)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                }
            }
            
        }
        .background(.gray)
        .listStyle(SidebarListStyle())
        .frame(width: 200)
        .transition(.move(edge: .leading))
        .zIndex(2)
       

    }
}

