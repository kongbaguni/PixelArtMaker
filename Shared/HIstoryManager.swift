//
//  HIstoryManager.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/20.
//

import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    private var undoStack = Stack<HistoryModel>()
    private var redoStack = Stack<HistoryModel>()

    public var undoCount:Int {
        undoStack.count
    }
    
    public var redoCount:Int {
        redoStack.count
    }
    
    public var totalCount:Int {
        undoCount + redoCount
    }
    
    public func addHistory(change:HistoryModel) {
        undoStack.push(change)
        redoStack.removeAll()
    }
    
    private func historyPorcess(isUndo:Bool) {
        guard let stage = StageManager.shared.stage,
              let history = isUndo ? undoStack.pop() : redoStack.pop() else {
            return
        }
        if let changes = history.colorChanges {
            var colors = stage.layers.map { layer in
                return layer.colors
            }
            
            for change in changes {
                colors[change.layerIndex][change.point.y][change.point.x] = isUndo
                ? change.colorChnage.before
                : change.colorChnage.after
            }
            for (idx,color) in colors.enumerated() {
                StageManager.shared.stage?.layers[idx] = .init(colors: color,
                                                               id: stage.layers[idx].id,
                                                               blendMode: stage.layers[idx].blendMode)
            }
        }
        if let changes = history.blendModeChanges {
            for bc in changes {
                let layer = stage.layers[bc.layerIndex]
                StageManager.shared.stage?.layers[bc.layerIndex] = .init(colors: layer.colors,
                                                                         id: layer.id,
                                                                         blendMode: isUndo ? bc.beforeBlendMode : bc.afetrBlendMode)
            }
        }
        if let change = history.backgroundColorChange {
            StageManager.shared.stage?.backgroundColor = isUndo ? change.before : change.after
        }
        isUndo ? redoStack.push(history) : undoStack.push(history)
    }
    
    public func undo() {
        historyPorcess(isUndo: true)
    }
    
    public func redo() {
       historyPorcess(isUndo: false)
    }
}
