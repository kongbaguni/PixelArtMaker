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
    
    let canvasSize:CGSize
    var backgroundColor:Color = .white
    var layers:[LayerModel] 

    var history = Stack<History>()
    var redoHistory = Stack<History>()
    
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
}
