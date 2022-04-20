import Foundation
import SwiftUI
import SwiftyJSON

struct HistorySet: Codable {
    let undo:[HistoryModel]
    let redo:[HistoryModel]
    var undoStack:Stack<HistoryModel> {
        .init(array: undo)
    }
    var redoStack:Stack<HistoryModel> {
        .init(array: redo)
    }
    
    var jsonValue:String {
        do {
            let data = try JSONEncoder().encode(self)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String:AnyObject] {

                if let str = JSON(json).rawString() {
                    return str
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
        
    static func makeModel(string:String)->HistorySet? {
        if let data = try? JSON(parseJSON: string).rawData() {
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
    let layerTotalEdit:LayerTotalChangeModel?
    
    init(colorChanges:Set<ColorChangeModelWithLayerPoint>? = nil , blendModeChanges:Set<BlendModeChangeModel>? = nil , backgroundColorChange:ColorChangeModel? = nil, layerTotalEdit:LayerTotalChangeModel? = nil) {
        self.colorChanges = colorChanges
        self.blendModeChanges = blendModeChanges
        self.backgroundColorChange = backgroundColorChange
        self.layerTotalEdit = layerTotalEdit
    }
    
    var isInvalid : Bool {
        colorChanges == nil && blendModeChanges == nil && backgroundColorChange == nil && layerTotalEdit == nil
    }
}

struct LayerTotalChangeModel : Codable, Hashable {
    let before:LayerTotalColorInfomationModel
    let after:LayerTotalColorInfomationModel
}

struct LayerTotalColorInfomationModel : Codable, Hashable {
    
    let c:[[[K_Color]]]
    let b:[Int32]
    let i:[String]
    
    init(layers:[LayerModel]) {
        self.c = layers.map({ layer in
              layer.colors.map { list in
                  list.map { c in
                      return K_Color(color: c)
                  }
              }
         })
        self.b = layers.map({ layer in
            return layer.blendMode.rawValue
        })
        self.i = layers.map({ layer in
            return layer.id
        })
    }
    
    var layers:[LayerModel] {
        var result:[LayerModel] = []
        for (idx,colors) in c.enumerated() {
            let cc = colors.map { list in
                list.map { c in
                    return c.color
                }
            }
            result.append(.init(colors: cc, id: i[idx], blendMode:CGBlendMode(rawValue:b[idx])!))
        }
        return result
    }
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
        b = .init(color: before)
        a = .init(color: after)
    }
    
    let b:K_Color
    let a:K_Color
    
    var before:Color {
        return b.color
    }
    var after:Color {
        return a.color
    }
    
}


struct K_Color:Codable, Hashable {
    public static func == (lhs:K_Color, rhs:K_Color) -> Bool {
        return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b && lhs.a == rhs.a
    }
    let r:Double
    let g:Double
    let b:Double
    let a:Double
    init(color:Color) {
        let c = color.ciColor
        r = c.red
        g = c.green
        b = c.blue
        a = c.alpha
    }
    
    var color:Color {
        Color(uiColor: UIColor(ciColor: CIColor(red: r, green: g, blue: b, alpha: a)))
    }
}

