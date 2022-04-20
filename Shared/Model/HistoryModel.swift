import Foundation
import SwiftUI
struct HistorySet: Codable {
    let undo:[HistoryModel]
    let redo:[HistoryModel]
    var jsonValue:[String:AnyObject]? {
        if let data = try? JSONEncoder().encode(self) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject] {
                return json
            }
        }
        return nil
    }
    static func makeModel(json:[String:AnyObject])->HistorySet? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return try? JSONDecoder().decode(HistorySet.self, from: data)
        }
        return nil
    }
}

struct HistoryModel: Codable, Hashable {
    public static func == (lhs:HistoryModel, rhs:HistoryModel) -> Bool {
        return lhs.colorChanges == rhs.colorChanges && lhs.backgroundColorChange == rhs.backgroundColorChange && lhs.blendModeChanges == rhs.blendModeChanges
    }
    let colorChanges:Set<ColorChangeModelWithLayerPoint>?
    let blendModeChanges:Set<BlendModeChangeModel>?
    let backgroundColorChange:ColorChangeModel?
}

struct ColorChangeModelWithLayerPoint :Codable, Hashable {
    public static func == (lhs:ColorChangeModelWithLayerPoint, rhs:ColorChangeModelWithLayerPoint) -> Bool {
        return lhs.layerIndex == rhs.layerIndex && lhs.x == rhs.x && lhs.y == rhs.y
    }
    let layerIndex:Int
    let x:Int
    let y:Int
    let colorChnage:ColorChangeModel
    
    init(layerIndex:Int, point:PathFinder.Point, change:ColorChangeModel) {
        self.layerIndex = layerIndex
        self.x = point.x
        self.y = point.y
        self.colorChnage = change
    }

    var point:PathFinder.Point {
        return .init(x: x, y: y)
    }
}

struct BlendModeChangeModel: Codable, Hashable {
    public static func == (lhs:BlendModeChangeModel, rhs:BlendModeChangeModel) -> Bool {
        return lhs.layerIndex == rhs.layerIndex && lhs.beforeBlendMode == rhs.beforeBlendMode && lhs.afetrBlendMode == rhs.afetrBlendMode
    }
    let layerIndex:Int
    let beforeBlendModeRawValue:Int32
    let afterBlendModeRawValue:Int32

    init(layerIndex:Int, blendModeBefore:CGBlendMode, blendModeAfter:CGBlendMode) {
        self.layerIndex = layerIndex
        self.beforeBlendModeRawValue = blendModeBefore.rawValue
        self.afterBlendModeRawValue = blendModeAfter.rawValue
    }

    var beforeBlendMode:CGBlendMode {
        .init(rawValue: beforeBlendModeRawValue)!
    }
    public var afetrBlendMode:CGBlendMode {
        .init(rawValue: afterBlendModeRawValue)!
    }
}

struct ColorChangeModel : Codable, Hashable {
    public static func == (lhs:ColorChangeModel, rhs:ColorChangeModel) -> Bool {
        return lhs.before == rhs.before && lhs.after == rhs.after
    }
    public init(before:Color, after:Color) {
        let b = before.ciColor
        br = b.red
        bg = b.green
        bb = b.blue
        ba = b.alpha
        let a = after.ciColor
        ar = a.red
        ag = a.green
        ab = a.blue
        aa = a.alpha
    
    }
    let br:Double
    let bg:Double
    let bb:Double
    let ba:Double
    
    let ar:Double
    let ag:Double
    let ab:Double
    let aa:Double
    
    var before:Color {
        return Color(.sRGB, red: br, green: bg, blue: bb, opacity: ba)
    }
    var after:Color {
        return Color(.sRGB, red: ar, green: ag, blue: ab, opacity: aa)
    }
    
}


