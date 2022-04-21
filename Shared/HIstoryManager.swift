//
//  HIstoryManager.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/20.
//

import Foundation
extension Notification.Name {
    static let historyDataDidChanged = Notification.Name(rawValue: "historyDataDidChanged")
}

class HistoryManager {
    init() {
        undoStack.setLimit(40)
        redoStack.setLimit(40)
    }
    
    static let shared = HistoryManager()
    
    private var undoStack = Stack<HistoryModel>()
    private var redoStack = Stack<HistoryModel>()
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    func load() {
        if let set = HistorySet.loadFromLocalDB() {
            undoStack = set.undoStack
            redoStack = set.redoStack
        }
    }
    
    func save() {
        HistorySet(undo: undoStack.arrayValue, redo: redoStack.arrayValue).saveToLocalDB()
    }
    
    public var undoCount:Int {
        undoStack.count
    }
    
    public var redoCount:Int {
        redoStack.count
    }
    
    public var totalCount:Int {
        undoCount + redoCount
    }
    
    public func addHistory(_ change:HistoryModel) {
        if change.isInvalid == false {
            undoStack.push(change)
            redoStack.removeAll()
            NotificationCenter.default.post(name: .historyDataDidChanged, object: nil, userInfo: [
                "undoCount":undoCount,
                "redoCount":redoCount,
                "totalCount":totalCount
            ])
        }
        save()
    }
    
    private func historyPorcess(isUndo:Bool)->Bool {
        guard let stage = StageManager.shared.stage,
              let history = isUndo ? undoStack.pop() : redoStack.pop() else {
            return false
        }
        if let changes = history.colorChanges {
            var colors = stage.layers.map { layer in
                return layer.colors
            }
            
            for change in changes {
                if change.layerIndex >= colors.count {
                    continue
                }
                if change.point.isIn(size: StageManager.shared.canvasSize) == false {
                    continue
                }
                
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
        if let change = history.layerTotalEdit {
            let data = isUndo ? change.before : change.after
            StageManager.shared.stage?.layers = data.layers
        }
        isUndo ? redoStack.push(history) : undoStack.push(history)
        return true
    }
    
    public func undo()->Bool {
        return historyPorcess(isUndo: true)
    }
    
    public func redo()->Bool {
        return historyPorcess(isUndo: false)
    }
}
