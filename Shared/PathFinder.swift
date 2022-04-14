//
//  PathFinder.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/14.
//

import Foundation
import UIKit

class PathFinder {
    struct Point {
        let x:Int
        let y:Int
        
        public static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
        public static func + (lhs: Point, rhs: Point) -> Point {
            return .init(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
        }
    }
    let canvasSize:(width:Int,height:Int)
    init(canvasSize:(width:Int,height:Int)) {
        self.canvasSize = canvasSize
    }
    
    init(cgSize:CGSize) {
        self.canvasSize = (width:Int(cgSize.width), height: Int(cgSize.height))
    }
    
    var paths:[[Point]] = []
    var count = 0
    var findFinish:Bool = false
    
    func findPathWithCGPoint(a:CGPoint,b:CGPoint,complete:@escaping(_ result:[Point]?)->Void) {
        let na = Point(x: Int(a.x), y: Int(a.y))
        let nb = Point(x: Int(b.x), y: Int(b.y))
        findPath(a: na, b: nb) { result in
            complete(result)
        }
    }
    
    func findPath(a:Point,b:Point, complete:@escaping(_ result:[Point]?)->Void) {
        if a.x >= canvasSize.width ||
            a.y >= canvasSize.height ||
            b.x >= canvasSize.width ||
            b.y >= canvasSize.height ||
            a.x < 0 ||
            a.y < 0 ||
            b.x < 0 ||
            b.y < 0 {
            complete(nil)
            return
        }
            
        enum Vec {
            case up
            case down
            case left
            case right
        }
        
        var checkVec:Set<Vec> {
            if a == b {
                return []
            }
            var result:Set<Vec> = []
            if a.x < b.x {
                result.insert(.right)
            }
            if a.x > b.x  {
                result.insert(.left)
            }
            if a.y < b.y {
                result.insert(.down)
            }
            if a.y > b.y {
                result.insert(.up)
            }
            return result
        }
                        
        func find(serchVecs : [Point], array:[Point]? = nil , pointer:Point) {
            
            for vec in serchVecs {
                var result:[Point] = array ?? [pointer]
                let np = pointer + vec
                result.append(np)
                if np == b {
                    count -= 1
                    self.paths.append(result)
                    print("----------------- path find \(paths.count) result: \(result.count) count: \(count)")
                    if count <= 0 && path.count > 0 {
                        findFinish = true

//                        complete(paths.randomElement())
                        let result = paths.sorted { a, b in
                            a.count < b.count
                        }.first
                        complete(result)
                    }
                    continue
                }
                if a.x < b.x && np.x > b.x
                    || a.x > b.x && np.x < b.x
                    || a.y < b.y && np.y > b.y
                    || a.y > b.y && np.y < b.y
                    || np.x < 0
                    || np.y < 0
                    || np.x >= canvasSize.width
                    || np.y >= canvasSize.height
                {
                    count -= 1
                    continue
                }
                
                count += 1
                find(serchVecs: serchVecs.shuffled(), array: result, pointer: np)
            }
        }
        
        func findPath(vec:Set<Vec>)->[Point]? {
            switch vec {
            case [.up]:
                var result:[Point] = []
                for i in b.y...a.y {
                    result.append(.init(x: a.x, y: i))
                }
                paths.append(result)
                return result
            case [.down]:
                var result:[Point] = []
                for i in a.y...b.y {
                    result.append(.init(x: a.x, y: i))
                }
                return result
            case [.left]:
                var result:[Point] = []
                for i in b.x...a.x {
                    result.append(.init(x: i, y: a.y))
                }
                return result
            case [.right]:
                var result:[Point] = []
                for i in a.x...b.x {
                    result.append(.init(x: i, y: a.y))
                }
                return result
            case []:
                return [a]
            case [.up,.right]:
                find(serchVecs: [Point(x: 1, y: -1),Point(x: 0, y: -1),Point(x: 1, y: 0)], array: nil, pointer: a)
            case [.down, .right]:
                find(serchVecs: [Point(x: 1, y: 1),Point(x: 0, y: 1),Point(x: 1, y: 0)], array: nil, pointer: a)
            case [.up, .left]:
                find(serchVecs: [Point(x: -1, y: -1),Point(x: 0, y: -1),Point(x: -1, y: 0)], array: nil, pointer: a)
            case [.down, .left]:
                find(serchVecs: [Point(x: -1, y: 1),Point(x: 0, y: 1),Point(x: -1, y: 0)], array: nil, pointer: a)
            default:
                break
            }
            return nil

        }
        
        if let result = findPath(vec: checkVec) {
            complete(result)
        }
    }
}
