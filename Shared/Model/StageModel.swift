//
//  StageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/18.
//

import Foundation
import SwiftUI

class StageModel {
    var layers:[LayerModel] 

    init(canvasSize:CGSize) {
        layers = [
            LayerModel(size: canvasSize)
        ]
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
    
    func change(layer:LayerModel) {
        layers[selectedLayerIndex] = layer
    }
}
