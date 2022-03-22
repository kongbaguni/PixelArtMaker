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
}

class StageModel {
    struct History {
        let layers:[LayerModel]
        let selectedLayerIndex:Int
    }
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
            LayerModel(size: canvasSize)
        ]
        self.canvasSize = canvasSize
    }
    
    var selectedLayerIndex:Int = 0
    
    var selectedLayer:LayerModel {
        if layers.count > selectedLayerIndex {
            return layers[selectedLayerIndex]
        }
        else {
            selectedLayerIndex = layers.count - 1
            return layers.last!
        }
    }
    
    func selectLayer(index:Int) {
        if index < layers.count {
            selectedLayerIndex = index
        }
    }
    
    func change(colors:[[Color]]) {
        history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex))
        layers[selectedLayerIndex] = .init(colors: colors, id:"layer\(selectedLayerIndex)")
        redoHistory.removeAll()
    }
    
    func addLayer() {
        layers.append(.init(size: canvasSize))
    }
    
    func undo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = history.pop() {
            redoHistory.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex))
            layers = data.layers
            selectedLayerIndex = data.selectedLayerIndex
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
        print("e history: \(history.count) redo: \(redoHistory.count)")
        print("---")
    }
    
    func redo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = redoHistory.pop() {
            history.push(.init(layers: layers, selectedLayerIndex: selectedLayerIndex))
            layers = data.layers
            selectedLayerIndex = data.selectedLayerIndex
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
            "redo_layer_colors":redo.colors
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
    
    static func makeModel(base64EncodedString:String)->StageModel? {
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
                if let p = json["pallete_colors"] as? [String] {
                    model.paletteColors = p.map({ str in
                        return Color(string: str)
                    })
                }
                var layers:[LayerModel] = []
                if let colors = json["colors"] as? [[[String]]] {
                    let arr = getColor(arr: colors)
                    for (idx,data) in arr.enumerated() {
                        layers.append(LayerModel(colors: data, id: "layer\(idx)"))
                    }
                }
                model.layers = layers
                
                func make(indexs:[Int],list:[[[[String]]]])->[History] {
                    var result:[History] = []
                    for (idx,strs) in list.enumerated() {
                        let colors = getColor(arr: strs)
                        var layers:[LayerModel] = []
                        for (i,color) in colors.enumerated() {
                            layers.append(.init(colors: color, id: "layer\(i)"))
                        }
                        result.append(.init(layers: layers, selectedLayerIndex: indexs[idx]))
                    }
                    return result
                }
                model.history.removeAll()
                if let ls = json["undo_layer_selection"] as? [Int], let cs = json["undo_layer_colors"] as? [[[[String]]]] {
                    for h in make(indexs: ls, list: cs) {
                        model.history.push(h)
                    }
                }

                model.redoHistory.removeAll()
                if let ls = json["redo_layer_selection"] as? [Int], let cs = json["redo_layer_colors"] as? [[[[String]]]] {
                    for h in make(indexs: ls, list: cs) {
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
    
}
