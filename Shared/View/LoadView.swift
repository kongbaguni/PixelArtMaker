//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

fileprivate let width1 = screenBounds.width / 2 - 10
fileprivate let width2 = screenBounds.width - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50

struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var stages:[StagePreviewModel] = []
    @State var gridItems:[GridItem] = [
        .init(.fixed(width1)),
        .init(.fixed(width1))
    ]
    @State var loadingStart = false
    var body: some View {
            
        ScrollView {
            if stages.count == 0 {
                Text("empty gallery title").padding(20)
            }
            if loadingStart {
                Text("open start").padding(20)
            }
            LazyVGrid(columns: gridItems, spacing:20) {
                ForEach(stages, id: \.self) {stage in
                    Button {
                        if loadingStart == false {
                            loadingStart = true
                            stages = [stage]
                            gridItems = [.init(.fixed(width2))]
                            StageManager.shared.openStage(id: stage.documentId) { result in
                                StageManager.shared.saveTemp {
                                    presentationMode.wrappedValue.dismiss()
                                }                                
                            }
                        }
                    } label : {
                        VStack {
                            ZStack {
                                Image(uiImage: stage.image).resizable().frame(width: loadingStart ? width2 : width1,
                                                                              height: loadingStart ? width2 : width1,
                                                                              alignment: .center)
                                .opacity(loadingStart ? 0.2 : 1.0)
                                ActivityIndicator(isAnimating: $loadingStart, style: .large)
                                    .frame(width: loadingStart ? width2 : width1,
                                           height: loadingStart ? width2 : width1, alignment: .center)
                            }
                            Text(stage.documentId)
                                .font(SwiftUI.Font.system(size: loadingStart ? 16 : 8))
                                .padding(5)
                                .foregroundColor(.k_tagText)
                                .background(Color.k_tagBackground)
                                .cornerRadius(10)
                            Text(stage.updateDt.formatted(date:.long, time: .standard))
                                .font(SwiftUI.Font.system(size: loadingStart ? 16 : 8))
                                .padding(5)
                                .foregroundColor(.k_tagText)
                                .background(Color.k_tagBackground)
                                .cornerRadius(10)
                            
                        }.frame(width: loadingStart ? width2 + 10 : width1,
                                height: loadingStart ? height2 + 10 : height1,
                                alignment: .center)
                    }

                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            load()
            if stages.count == 0 {
                StageManager.shared.loadList { result in
                    load()
                }
            }
        }
    }
    func load() {
        stages = StageManager.shared.stagePreviews
        gridItems = stages.count > 1 ? [.init(.fixed(width1)),.init(.fixed(width1))] : [.init(.fixed(width2))]
        
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
