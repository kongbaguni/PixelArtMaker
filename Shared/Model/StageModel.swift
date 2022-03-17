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
    let canvasSize:CGSize
    var backgroundColor:Color = .white
    var layers:[LayerModel] 

    var history = Stack<[LayerModel]>()
    var redoHistory = Stack<[LayerModel]>()
    
    init(canvasSize:CGSize) {
        layers = [
            LayerModel(size: canvasSize)
        ]
        self.canvasSize = canvasSize
    }
    
    var selectedLayerIndex:Int = 0
    
    var selectedLayer:LayerModel {
        return layers[selectedLayerIndex]
    }
    
    func selectLayer(index:Int) {
        if index < layers.count {
            selectedLayerIndex = index
        }
    }
    
    func change(colors:[[Color]]) {
        history.push(layers)
        let ol = layers[selectedLayerIndex]
        layers[selectedLayerIndex] = .init(colors: colors, isOn: ol.isOn, opacity: ol.opacity, id:"layer\(selectedLayerIndex)")
        redoHistory.removeAll()
    }
    
    func addLayer() {
        layers.append(.init(size: canvasSize))
    }
    
    func undo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = history.pop() {
            redoHistory.push(layers)
            layers = data
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
        print("e history: \(history.count) redo: \(redoHistory.count)")
        print("---")
    }
    
    func redo() {
        print("s history: \(history.count) redo: \(redoHistory.count)")
        if let data = redoHistory.pop() {
            history.push(layers)
            layers = data
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
        print("e history: \(history.count) redo: \(redoHistory.count)")
        print("---")
    }
}
