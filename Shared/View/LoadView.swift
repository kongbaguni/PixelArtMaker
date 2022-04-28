//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import SDWebImageSwiftUI

//import RealmSwift


struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var stages:[MyStageModel.ThreadSafeModel] = []

    @State var loadStage:MyStageModel.ThreadSafeModel? = nil
    @State var loadingStart = false
    @State var sortIndex = 0

    var sortType:Sort.SortType {
        return Sort.SortTypeForMyGellery[sortIndex]
    }

    @State var isShowInAppPurch = false
    private var pickerView : some View {
        Picker(selection:$sortIndex, label:Text("sort")) {
            ForEach(0..<Sort.SortTypeForMyGellery.count, id:\.self) { idx in
                let type = Sort.SortTypeForMyGellery[idx]
                Sort.getText(type: type)
            }
        }.onChange(of: sortIndex) { newValue in
            withAnimation(.easeInOut) {
                load(animate: true)
            }
        }
    }
    
    private func getWidth(width:CGFloat,number:Int)->CGFloat {
        switch number {
        case 0:
            return 0
        case 1:
            return width - 10
        default:
            return (width - 40) / CGFloat(number)
        }
    }
    private func isOverLimit(stage:MyStageModel.ThreadSafeModel)->Bool {
        if InAppPurchaseModel.isSubscribe {
            return false
        }
        
        if let index = stages.firstIndex(of: stage) {
            switch sortType {
            case .oldnet:
                if stages.count - index > Consts.free_myGalleryLimit {
                    return true
                }
            case .latestOrder:
                if index >= Consts.free_myGalleryLimit {
                    return true
                }
            default:
                break
            }
        }
        return false
    }
    private func makeListView(gridItems:[GridItem], width:CGFloat) -> some View {
        Group {
            NavigationLink(isActive: $isShowInAppPurch) {
                InAppPurchesView()
            } label: {
                
            }

            LazyVGrid(columns: gridItems, spacing:20) {
                ForEach(stages, id: \.self) {stage in
                    Button {
                        if isOverLimit(stage: stage) {
                            isShowInAppPurch = true
                            return
                        }
                        if loadingStart == false {
                            loadStage = stage
                            loadingStart = true
                            StageManager.shared.openStage(id: stage.documentId) { (result,errorA) in
                                StageManager.shared.saveTemp { errorB in
                                    if errorA == nil && errorB == nil {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    } else {
                                        loadingStart = false
                                    }
                                    isShowToast = errorA != nil || errorB != nil
                                    toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                }
                            }
                        }
                    } label : {
                        VStack {
                            FSImageView(imageRefId: stage.documentId, placeholder: .imagePlaceHolder)
                                .frame(width: getWidth(width: width, number: gridItems.count),
                                                   height: getWidth(width: width, number: gridItems.count),
                                                   alignment: .center)
                            HStack {
                                Text("id").font(.system(size: 10))
                                Text(stage.documentId)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            HStack {
                                Text("update").font(.system(size:10))
                                Text(stage.updateDt.formatted(date:.long, time: .standard))
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            Spacer()
                        }.frame(width: loadingStart && stages.count == 1 ? getWidth(width: width, number: 1) : getWidth(width: width, number: gridItems.count),
                                height: loadingStart && stages.count == 1 ? getWidth(width: width, number: 1) + 30 : getWidth(width: width, number: gridItems.count) + 30 ,
                                alignment: .center)
                        .opacity(isOverLimit(stage: stage) ? 0.2 : 1.0)
                    }
                    
                }
            }
            .opacity(loadingStart ? 0.5 : 1.0)
            .padding(.horizontal)
        }
//        .animation(.easeInOut, value: loadingStart)

    }
    
    private func load(animate:Bool = false) {
        if animate {
            loadingStart = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                loadingStart = false
            }
        }
        switch sortType {
        case .latestOrder:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: true).reversed().map({ model in
                return model.threadSafeModel
            })
        case .oldnet:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: false).reversed().map({ model in
                return model.threadSafeModel
            })
        default:
            stages = []
        }
    }
    
    func makePreviewLoadView()-> some View {
        ZStack {
            VStack {
                Spacer()
                if let id = loadStage?.documentId {
                    HStack {
                        Spacer()
                        FSImageView(imageRefId: id, placeholder: .imagePlaceHolder)
                            .frame(width: CGSize.getImageSizeForPreviewImage(padding: 40).width,
                                   height: CGSize.getImageSizeForPreviewImage(padding: 40).height,
                                   alignment: .center)
                            .opacity(0.3)
                        Spacer()
                    }
                }
                Spacer()
            }
            VStack {
                ActivityIndicator(isAnimating: $loadingStart, style: .large)
                if loadingStart {
                    Text("open start").padding(20)
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if loadingStart && loadStage != nil {
                makePreviewLoadView()
            }
            ScrollView {
                BannerAdView(sizeType: .GADAdSizeBanner, padding:.init(top: 20, left: 0, bottom: 20, right: 0))
                if stages.count > 0 {
                    pickerView
                }
                if stages.count == 0 {
                    Text(loadingStart ? "open start" : "empty gallery title").padding(20)
                }
                makeListView(gridItems:Utill.makeGridItems(length: geomentry.size.width < geomentry.size.height ? 2 : 4 , screenWidth: geomentry.size.width, padding:20)
                             ,width:geomentry.size.width)
            }
                        
        }
        .navigationBarTitle(Text("my gellery"))
        .onAppear {
            load()
            loadingStart = true
            StageManager.shared.loadList { sucess in
                load()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {[self] in
                    loadingStart = false
                }
            }
            
        }
    }
    
    
   
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
