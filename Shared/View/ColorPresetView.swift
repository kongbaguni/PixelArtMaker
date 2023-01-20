//
//  ColorPresetView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/18.
//

import SwiftUI

fileprivate func getW(name:String,idx:Int)->CGFloat {
    if let list = Color.presetColors[name] {
        let count = list[idx].count
        return (screenBounds.width - 120) / CGFloat(count)
    }
    return 0.0
}




struct ColorPresetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    struct RowData : Hashable {
        public static func == (lhs: RowData, rhs: RowData) -> Bool {
            return lhs.title == rhs.title && lhs.colors == rhs.colors
        }
        let title:String?
        let colors:[Color]?
        let indexPath:IndexPath?
    }
    
    let datas:[RowData]
    @State var selectedData:RowData? = nil
    
    private var colorPresetNames:[String] {
        Color.colorPresetNames
    }
    
    private var colors:[[[Color]]] {
        colorPresetNames.map { key in
            let arr = Color.presetColors[key]
            return arr ?? []
        }
    }

    private var selectedIndexPath:IndexPath? {
        for (section, list) in colors.enumerated() {
            for (row, colors) in list.enumerated() {
                if colors == StageManager.shared.stage?.paletteColors {
                    let result = IndexPath(row: row, section: section)
                    print("selection : \(result)" )
                    return result
                }
            }
        }
        let result = UserDefaults.standard.lastColorPresetIndexPath
        if result.row > 0 {
            return result
        }

        print("selection none")
        return nil
    }
    
    private func getId(indexPath:IndexPath)->Int {
        var id = 0
        for i in 0..<indexPath.section {
            if i == indexPath.section {
                continue
            }
            id += colors[i].count + 1
        }
        id += indexPath.row + 1
        return id
    }
    
    private var selectedId:Int? {
        if let idx = selectedIndexPath {
            return getId(indexPath: idx)
        }
        return nil
    }
    
    
    private func makeColorsView(key:String,colors:[Color], indexPath:IndexPath)-> some View  {
        HStack {
            Text("\(indexPath.row + 1)")
            
            ForEach(0..<colors.count, id:\.self) { i in
                Text(" ")
                    .frame(width: getW(name:key,idx:i),
                           height: 50,
                           alignment: .center)
                    .background(colors[i])
            }
        }
        .padding(5)
        .background(indexPath == selectedData?.indexPath ? Color.K_boldText : Color.clear)
        .cornerRadius(10)
    }
    
    private var fullList : some View {
        ScrollView {
            BannerAdView(sizeType: .GADAdSizeBanner)
                .padding(.top,20).padding(.bottom,20)
            LazyVStack {
                ForEach(datas, id:\.self) { data in
                    if let key = data.title {
                        if data.indexPath == nil {
                            Text(key)
                                .font(.headline)
                                .foregroundColor(Color.K_boldText)
                        }
                        if let colors = data.colors, let indexPath = data.indexPath {
                            Button {
                                StageManager.shared.stage?.paletteColors = colors
                                UserDefaults.standard.lastColorPresetIndexPath = indexPath
                                presentationMode.wrappedValue.dismiss()
                                
                            } label : {
                                makeColorsView(key:key,colors: colors, indexPath: indexPath)
                            }
                        }
                    }
                }
            }
        }
    }
        
    init() {
        var data:[RowData] = []
        for (section,key) in Color.colorPresetNames.enumerated() {
            data.append(.init(title: key, colors: nil, indexPath: nil))
            for (row,colors) in (Color.presetColors[key] ?? []).enumerated() {
                data.append(.init(title: key, colors: colors, indexPath: .init(row: row, section: section)))
            }
        }
        self.datas = data
        
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ScrollViewReader { proxy in
                fullList.onAppear {
                    if let idx = selectedId {
                        selectedData = datas[idx]
                        proxy.scrollTo(datas[idx], anchor: .center)                        
                    }
                }
            }.frame(width: geomentry.size.width, height: geomentry.size.height)
        }
        .navigationTitle(Text.menu_color_select_title)
    }
}

struct ColorPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPresetView()
    }
}
