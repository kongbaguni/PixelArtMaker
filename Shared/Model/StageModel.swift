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

class StageModel {
    struct History {
        let layers:[LayerModel]
        let selectedLayerIndex:Int
        let backgroundColor:Color
    }
    var createrId:String = ""
    var documentId:String? = nil
    var previewImage:UIImage? = nil
    
    var paletteColors:[Color] = [.red,.orange,.yellow,.green,.blue,.purple,.black]
    
    let canvasSize:CGSize
    var forgroundColor:Color = .red
    var backgroundColor:Color = .white
    var layers:[LayerModel] 

    var history = Stack<History>()
    var redoHistory = Stack<History>()
    
    var title:String? = nil
    
    init(canvasSize:CGSize) {
        layers = [
            LayerModel(size: canvasSize, blendMode: .normal)
        ]
        history.setLimit(20)
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
        }
    }
    
    func changeBgColor(color:Color)->Bool {
        if backgroundColor != color {
            history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
            backgroundColor = color
            redoHistory.removeAll()
            return true
        }
        return false
    }
    
    func change(colors:[[Color]]) {
        print("\(#function) layeridx : \(selectedLayerIndex)")
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
        let blendMode = layers[selectedLayerIndex].blendMode
        layers[selectedLayerIndex] = .init(colors: colors, id:"layer\(selectedLayerIndex)", blendMode:blendMode)
        redoHistory.removeAll()
    }
    
    
    func change(blendMode:CGBlendMode, layerIndex:Int) {
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex,backgroundColor: backgroundColor))
        let layer = layers[layerIndex]
        if layer.blendMode != blendMode {
            layers[layerIndex] = .init(colors: layer.colors, id: layer.id, blendMode: blendMode)
            NotificationCenter.default.post(name: .layerblendModeDidChange, object: nil)
        }
        redoHistory.removeAll()
    }
    
    func deleteLayer(idx:Int) {
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
        layers.remove(at: idx)
        redoHistory.removeAll()
    }
    
    func addLayer() {
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
        layers.append(.init(size: canvasSize, blendMode: .normal))        
        redoHistory.removeAll()
    }
    
    func undo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = history.pop() {
            redoHistory.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
            layers = data.layers
            selectLayer(index: data.selectedLayerIndex)
            backgroundColor = data.backgroundColor
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
        print("e history: \(history.count) redo: \(redoHistory.count)")
        print("---")
    }
    
    func redo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = redoHistory.pop() {
            history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
            layers = data.layers
            selectLayer(index: data.selectedLayerIndex)
            backgroundColor = data.backgroundColor
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
        print("e history: \(history.count) redo: \(redoHistory.count)")
        print("---")
    }
    
    var base64EncodedString:String {
        func getColorStrings(colorArray:[[[Color]]])->[[[String]]] {
            var colorStrings:[[[String]]] = []
            for arr1 in colorArray {
                var a:[[String]] = []
                for arr2 in arr1 {
                    var b:[String] = []
                    for c in arr2 {
                        b.append(c.string)
                    }
                    a.append(b)
                }
                colorStrings.append(a)
            }
            return colorStrings
        }
        
        func getHistoryStrings(history:[History])->(selection:[Int], colors:[[[[String]]]]){
            let layerSelection = history.map { history in
                return history.selectedLayerIndex
            }
            let layers = history.map { history in
                return history.layers.map { layer in
                    return layer.colors
                }
            }
            let colors = layers.map { arr in
                return getColorStrings(colorArray: arr)
            }

            return (selection:layerSelection, colors:colors)
        }
        
        let undo = getHistoryStrings(history: history.arrayValue)
        let redo = getHistoryStrings(history: redoHistory.arrayValue)
             
        let blendModes = layers.map { model in
            return model.blendMode.rawValue
        }
        
        let undoblendModes = history.arrayValue.map { history in
            return history.layers.map { layer in
                return layer.blendMode.rawValue
            }
        }
        let redoblendModes = history.arrayValue.map { history in
            return history.layers.map { layer in
                return layer.blendMode.rawValue
            }
        }
        let undoBackgroundColors = history.arrayValue.map { history in
            return history.backgroundColor.string
        }
        let redoBackgroundColors = redoHistory.arrayValue.map { history in
            return history.backgroundColor.string
        }
        
        let dic:[String:AnyHashable] = [
            "title":title,
            "colors":getColorStrings(colorArray: layers.map({ model in
                return  model.colors
            })),
            "pallete_colors":paletteColors.map({ color in
                return color.string
            }),
            "canvas_width":canvasSize.width,
            "canvas_height":canvasSize.height,
            "background_color":backgroundColor.string,
            "forground_color":forgroundColor.string,
            
            "undo_layer_selection":undo.selection,
            "undo_layer_colors":undo.colors,
            "redo_layer_selection":redo.selection,
            "redo_layer_colors":redo.colors,
            "bland_modes":blendModes,
            "undo_bland_modes":undoblendModes,
            "redo_bland_modes":redoblendModes,
            "selected_layer_index":selectedLayerIndex,
            "undo_background_colors":undoBackgroundColors,
            "redo_background_colors":redoBackgroundColors
        ]
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let compresedData = try (jsonData as NSData).compressed(using: .lzfse)
            return compresedData.base64EncodedString()
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
   
    
    static func makeModel(base64EncodedString:String, documentId:String?)->StageModel? {
        func getColor(arr:[[[String]]])->[[[Color]]] {
            var result:[[[Color]]] = []
            for arr1 in arr {
                var a:[[Color]] = []
                for arr2 in arr1 {
                    var b:[Color] = []
                    for str in arr2 {
                        b.append(Color(string: str))
                    }
                    a.append(b)
                }
                result.append(a)
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
                model.title = json["title"] as? String ?? ""
                model.forgroundColor = Color(string: (json["forground_color"] as? String) ?? "1 0 0 1")
                model.documentId = documentId
                if let idx = json["selected_layer_index"] as? Int {
                    model.selectLayer(index: idx)
                }

                if let p = json["pallete_colors"] as? [String] {
                    model.paletteColors = p.map({ str in
                        return Color(string: str)
                    })
                }
                var layers:[LayerModel] = []
                let blendModes = json["bland_modes"] as? [Int32]
                let undoblendModes = json["undo_bland_modes"] as? [[Int32]]
                let redoblendModes = json["redo_bland_modes"] as? [[Int32]]
                
                
                if let colors = json["colors"] as? [[[String]]] {
                    let arr = getColor(arr: colors)
                    for (idx,data) in arr.enumerated() {
                        layers.append(LayerModel(colors: data, id: "layer\(idx)", blendMode: .init(rawValue: blendModes?[idx] ?? 0) ?? .normal))
                    }
                }
                model.layers = layers
                
                func make(indexs:[Int],list:[[[[String]]]], blendModes:[[Int32]], bgColors:[Color])->[History] {
                    var result:[History] = []
                    for (idx,strs) in list.enumerated() {
                        let colors = getColor(arr: strs)
                        var layers:[LayerModel] = []
                        for (i,color) in colors.enumerated() {
                            
                            var blendMode:CGBlendMode = .normal
                            if blendModes.count > idx {
                                if blendModes[idx].count > i {
                                    blendMode = .init(rawValue: blendModes[idx][i]) ?? .normal
                                }
                            }
                            
                            layers.append(.init(colors: color, id: "layer\(i)", blendMode: blendMode ))
                        }
                        result.append(.init(layers: layers, selectedLayerIndex: indexs[idx], backgroundColor: bgColors[idx]))
                    }
                    return result
                }
                model.history.removeAll()
                
                
                

                if let ls = json["undo_layer_selection"] as? [Int],
                   let cs = json["undo_layer_colors"] as? [[[[String]]]],
                   let undoBgColors = json["undo_background_colors"] as? [String],
                   let bl = undoblendModes {
                    let bgc = undoBgColors.map { str in
                        return Color(string: str)
                    }
                    for h in make(indexs: ls, list: cs, blendModes: bl, bgColors: bgc) {
                        model.history.push(h)
                    }
                }

                model.redoHistory.removeAll()
                if let ls = json["redo_layer_selection"] as? [Int],
                   let cs = json["redo_layer_colors"] as? [[[[String]]]],
                   let redoBgColors = json["redo_background_colors"] as? [String],
                   let bl = redoblendModes
                {
                    let bgc = redoBgColors.map { str in
                        return Color(string: str)
                    }

                    for h in make(indexs: ls, list: cs, blendModes: bl, bgColors: bgc) {
                        model.redoHistory.push(h)
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
            let image = Image(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor,  size: size)
            DispatchQueue.main.async {
                complete(image)
            }
        }
    }
    
    func copyLayer(idx:Int)->Bool {
        if layers.count >= 5 || idx < 0 || idx >= layers.count {
            return false
        }
        let cl = layers[idx]
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex, backgroundColor: backgroundColor))
        let newLayer:LayerModel = .init(colors: cl.colors, id: UUID().uuidString, blendMode: cl.blendMode)
        layers.insert(newLayer, at: idx)
        reArrangeLayers()
        redoHistory.removeAll()

        return true
    }
    
    /** 레이어 아이디 제할당 */
    func reArrangeLayers() {
        for (idx,layer) in layers.enumerated() {
            layers[idx] = .init(colors: layer.colors, id: "layer\(idx)", blendMode: layer.blendMode)
        }
    }
    
    var isMyPicture:Bool {
        return createrId == AuthManager.shared.userId
    }
}
