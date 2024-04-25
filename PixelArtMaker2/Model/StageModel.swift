//
//  StageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/18.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let layerDataRefresh = Notification.Name("layerDataRefresh_observer")
    static let layerblendModeDidChange = Notification.Name("layerblendModeDidChange_observer")
}

struct StageDataModel : Codable, Hashable {
    public static func == (lhs:StageDataModel, rhs:StageDataModel) -> Bool {
        return lhs.documentId == rhs.documentId
    }
    var createrId:String
    var documentId:String?
    var canvasWidth:CGFloat
    var canvasHeight:CGFloat
    var forgroundColorModel:ColorModel
    var backgroundColorModel:ColorModel
    var layers:[LayerModelForSave]
    var isNSFW:Bool
    var selected_layer_index:Int
    
    var canvasSize:CGSize {
        return .init(width: canvasWidth, height: canvasHeight)
    }
    
    var forgroundColor:Color {
        get {
            forgroundColorModel.getColor(colorSpace: .sRGB)
        }
        set {
            forgroundColorModel = .init(color: newValue)
        }
    }
    
    var backgroundColor:Color {
        get {
            backgroundColorModel.getColor(colorSpace: .sRGB)
        }
        set {
            backgroundColorModel = .init(color: newValue)
        }
    }
    
    static let empty:StageDataModel = .init(createrId: "", canvasWidth: 0, canvasHeight: 0, forgroundColorModel: .clear, backgroundColorModel: .clear, layers: [], isNSFW: false, selected_layer_index: 0)
    
    
    static func makeModel(json:[String:AnyObject])->StageDataModel? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return try? JSONDecoder().decode(StageDataModel.self, from: data)
        }
        return nil
    }
    
    var jsonValue:[String:AnyObject]? {
        if let data = try? JSONEncoder().encode(self) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject] {
                return json
            }
        }
        return nil
    }
}


class StageModel {
    var data:StageDataModel = .empty
    
    var createrId:String  {
        set {
            data.createrId = newValue
        }
        get {
            data.createrId
        }
    }
    var documentId:String? {
        set {
            data.documentId = newValue
        }
        get {
            data.documentId
        }
    }
    
    var previewImage:UIImage? = nil
    
    var paletteColors:[Color] = [.red,.orange,.yellow,.green,.blue,.purple,.black]
    
    var canvasSize:CGSize {
        set {
            data.canvasWidth = newValue.width
            data.canvasHeight = newValue.height
        }
        get {
            data.canvasSize
        }
    }
    var forgroundColor:Color {
        set {
            data.forgroundColor = newValue
        }
        get {
            data.forgroundColor
        }
    }
    var backgroundColor:Color {
        set {
            data.backgroundColor = newValue
        }
        get {
            data.backgroundColor
        }
    }
    
    var layers:[LayerModel] = []

    var isNSFW:Bool {
        set {
            data.isNSFW = newValue
        }
        get {
            data.isNSFW
        }
    }
        
    init(canvasSize:CGSize) {
        layers = [
            LayerModel(size: canvasSize, blendMode: .normal)
        ]
        self.canvasSize = canvasSize
    }
    
    var totalColors:[[[Color]]] {
        return layers.map { layer in
            return layer.colors
        }
    }
    
    private var _selectedLayerIndex:Int = 0
    
    var selectedLayerIndex:Int {
        get {
            _selectedLayerIndex
        }
    }
    
        
    var selectedLayer:LayerModel {
        if layers.count > selectedLayerIndex {
            return layers[selectedLayerIndex]
        }
        else {
            selectLayer(index: layers.count - 1)
            return layers.last!
        }
    }
    
    func selectLayer(index:Int) {
        if index < layers.count {
            _selectedLayerIndex = index
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
    }
    
    func changeBgColor(color:Color)->Bool {
        if backgroundColor != color {
            HistoryManager.shared.addHistory(.init(backgroundColorChange: .init(before: backgroundColor, after: color)))
            backgroundColor = color
            return true
        }
        return false
    }
    
    

    func change(colors:[[Color]]) {
        print("\(#function) layeridx : \(selectedLayerIndex)")
        let blendMode = layers[selectedLayerIndex].blendMode
        layers[selectedLayerIndex] = .init(colors: colors, id:"layer\(selectedLayerIndex)", blendMode:blendMode)
    }
    
    func chnage(colorSet : Set<ColorChangeModelWithLayerPoint>) {
        var newColors = layers.map { layer in
            return layer.colors
        }
        for item in colorSet {
            newColors[item.layerIndex][item.y][item.x] = item.colorChnage.after
        }
        for (idx,colors) in newColors.enumerated() {
            layers[idx] = .init(colors: colors, id: layers[idx].id, blendMode: layers[idx].blendMode)
        }
    }
    
    
    func change(blendMode:CGBlendMode, layerIndex:Int, needAddHistory:Bool = true) {
        let before = layers[layerIndex].blendMode
        if needAddHistory {
            HistoryManager.shared.addHistory(.init(blendModeChanges: [.init(layerIndex: layerIndex, blendModeBefore: before, blendModeAfter: blendMode)]))
        }
        
        let layer = layers[layerIndex]
        if layer.blendMode != blendMode {
            layers[layerIndex] = .init(colors: layer.colors, id: layer.id, blendMode: blendMode)
            NotificationCenter.default.post(name: .layerblendModeDidChange, object: nil)
        }
    }
    
    func deleteLayer(idx:Int) {
        let oldLayers = layers
        layers.remove(at: idx)
        HistoryManager.shared.addHistory(.init(
            layerTotalEdit:.init(before: .init(layers: oldLayers),
                                 after: .init(layers: layers)))
        )
    }
    
    func addLayer() {
        let oldLayers = layers
        
        layers.append(.init(size: canvasSize, blendMode: .normal))
        
        HistoryManager.shared.addHistory(.init(
            layerTotalEdit:.init(before: .init(layers: oldLayers),
                                 after: .init(layers: layers)))
        )
    }
    
    func undo() {
        if HistoryManager.shared.undo() {
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
    }
    
    func redo() {
        if HistoryManager.shared.redo() {
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
    }
    
    var base64EncodedString:String {
        let slayers = layers.map { layer in
            return layer.saveModel
        }
        data.layers = slayers
        
        if let dic = data.jsonValue {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                let compresedData = try (jsonData as NSData).compressed(using: .lzfse)
                return compresedData.base64EncodedString()
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
   /** 구버전 세이브 로드 */
    static func makeModelOld(base64EncodedString:String, documentId:String?)->StageModel? {
        func getColor(arr:[[[String]]])->[[[Color]]] {
            
            func makeColor(stringArr c:String)->Color {
                let list = c.components(separatedBy: " ")
                let r = NSString(string:list[0]).doubleValue
                let g = NSString(string:list[1]).doubleValue
                let b = NSString(string:list[2]).doubleValue
                let a = NSString(string:list[3]).doubleValue
                return Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: a))
            }
            
            let result = arr.map { a in
                a.map { b in
                    b.map { c in
                        return makeColor(stringArr: c)
                    }
                }
            }
            return result
        }
        
        do {
            if let data = Data(base64Encoded: base64EncodedString) {
                let newData = try (data as NSData).decompressed(using: .lzfse) as Data
                guard let json = try JSONSerialization.jsonObject(with: newData) as? [String:Any],
                      let w = json["canvas_width"] as? CGFloat,
                      let h = json["canvas_height"] as? CGFloat else {
                    return nil
                }
                let model = StageModel(canvasSize: .init(width: w, height: h))
                model.backgroundColor = Color(string: (json["background_color"] as? String) ?? "1 1 1 1")
                model.forgroundColor = Color(string: (json["forground_color"] as? String) ?? "1 0 0 1")
                model.documentId = documentId
                if let isNSFW = json["isNSFW"] as? Bool {
                    model.isNSFW = isNSFW
                }
                if let idx = json["selected_layer_index"] as? Int {
                    model.selectLayer(index: idx)
                }

                if let color = Color.lastSelectColors {
                    model.paletteColors = color
                }
                else {
                    if let row = json["pallete_colors_idx_row"] as? Int,
                       let section = json["pallete_colors_idx_section"] as? Int {
                        if let colors = Color.getColorsFromPreset(indexPath: .init(row: row, section: section)) {
                            model.paletteColors = colors
                        }
                    }
                }
                var layers:[LayerModel] = []
                let blendModes = json["bland_modes"] as? [Int32]
                
                if let colors = json["colors"] as? [[[String]]] {
                    let arr = getColor(arr: colors)
                    for (idx,data) in arr.enumerated() {
                        layers.append(LayerModel(colors: data, id: "layer\(idx)", blendMode: .init(rawValue: blendModes?[idx] ?? 0) ?? .normal))
                    }
                }
                model.layers = layers
                                                
                
                return model
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func makeModel(base64EncodedString:String, documentId:String?)->StageModel? {
        func getColor(arr:[[[String]]])->[[[Color]]] {
            
            func makeColor(stringArr c:String)->Color {
                let list = c.components(separatedBy: " ")
                let r = NSString(string:list[0]).doubleValue
                let g = NSString(string:list[1]).doubleValue
                let b = NSString(string:list[2]).doubleValue
                let a = NSString(string:list[3]).doubleValue
                
                return Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: a))
            }
            
            let result = arr.map { a in
                a.map { b in
                    b.map { c in
                        return makeColor(stringArr: c)
                    }
                }
            }
            return result
        }
        
        do {
            if let data = Data(base64Encoded: base64EncodedString) {
                let newData = try (data as NSData).decompressed(using: .lzfse) as Data
                guard let json = try JSONSerialization.jsonObject(with: newData) as? [String:Any],
                      let stageData = StageDataModel.makeModel(json: json as [String:AnyObject]) else {
                    
                    return StageModel.makeModelOld(base64EncodedString: base64EncodedString, documentId: documentId)
                }
                
                let model = StageModel(canvasSize: stageData.canvasSize)
                model.data = stageData
                model.documentId = documentId
                model.layers = model.data.layers.map({ model in
                    return model.layerModel
                })
                model.selectLayer(index:stageData.selected_layer_index)

                if let color = Color.lastSelectColors {
                    model.paletteColors = color
                }
                else {
                    if let row = json["pallete_colors_idx_row"] as? Int,
                       let section = json["pallete_colors_idx_section"] as? Int {
                        if let colors = Color.getColorsFromPreset(indexPath: .init(row: row, section: section)) {
                            model.paletteColors = colors
                        }
                    }
                }                                                
                
                return model
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    var blendModes:[CGBlendMode] {
        return layers.map { layer in
            return layer.blendMode
        }
    }
    func makeImageDataValue(size:CGSize)->Data? {
        let image = UIImage(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor, size: size)
        return image?.pngData()
    }
    
    func getImage(size:CGSize, complete:@escaping(_ image:Image?)->Void) {
        let blendModes = layers.map { layer in
            return layer.blendMode
        }

        DispatchQueue.global().async {[self] in
//            let image = Image(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor,  size: size)
            
            guard let uiimage = UIImage(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor,  size: size) else {
                return
            }
            uiimage.saveImageForAppGroup(size: uiimage.size)
            let image = Image(uiImage: uiimage);            
            DispatchQueue.main.async {
                complete(image)
            }
        }
    }
    
    func copyLayer(idx:Int)->Bool {
        if layers.count >= 5 || idx < 0 || idx >= layers.count {
            return false
        }
        let bLayers = layers
        
        let cl = layers[idx]
        let newLayer:LayerModel = .init(colors: cl.colors, id: UUID().uuidString, blendMode: cl.blendMode)
        layers.insert(newLayer, at: idx)
        reArrangeLayers()
        
        HistoryManager.shared.addHistory(.init( layerTotalEdit: .init(before: .init(layers: bLayers), after: .init(layers: layers))))
        return true
    }
    
    /** 레이어 아이디 제할당 */
    func reArrangeLayers() {
        for (idx,layer) in layers.enumerated() {
            layers[idx] = .init(colors: layer.colors, id: "layer\(idx)", blendMode: layer.blendMode)
        }
    }
    
    var isMyPicture:Bool {
        return createrId == AuthManager.shared.userId || createrId.isEmpty
    }
}
