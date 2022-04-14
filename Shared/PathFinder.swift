//
//  PathFinder.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/14.
//

import Foundation
import UIKit

fileprivate extension CGPoint {
    var pointValue:PathFinder.Point {
        return .init(x: Int(x), y: Int(y))
    }
}

class PathFinder {
    struct Point : Hashable{
        let x:Int
        let y:Int
        
        public static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
        public static func + (lhs: Point, rhs: Point) -> Point {
            return .init(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
        }
        
        func distance(_ to:Point)->Int {
            let w = abs(x - to.x)
            let h = abs(y - to.y)
            return  w + h
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
         
            var result:[Point] = array ?? []
            let nextPoints = serchVecs.map { point in
                return point + pointer
            }
            let distances = nextPoints.map { point in
                return point.distance(b)
            }
            let s = distances.sorted().first!
            let idx = distances.firstIndex(of: s)!
            
            let np = nextPoints[idx]
            print(" distances:\(distances) s:\(s) idx: \(idx)")

            if np.x < 0 || np.x >= canvasSize.width || np.y < 0 || np.y >= canvasSize.height {
                print("!!!!!\(np)")
                return
            }
            result.append(np)
            if np == b || s == 0{
                print("complete")
                paths.append(result)
                complete(result)
                return
            }
            find(serchVecs: serchVecs, array: result, pointer: np)
            
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
    
    
    func findSquare(a:CGPoint, b:CGPoint, isFill:Bool = false)->Set<Point> {
        let a = a.pointValue
        let b = b.pointValue
        var result = Set<Point>()
        
        let rangex = a.x < b.x ? a.x...b.x : b.x...a.x
        let rangey = a.y < b.y ? a.y...b.y : b.y...a.y

        if isFill {
            for x in rangex {
                for y in rangey {
                    result.insert(.init(x: x, y: y))
                }
            }
        }
        else {
            for x in rangex {
                result.insert(.init(x: x, y: a.y))
                result.insert(.init(x: x, y: b.y))
            }
            for y in rangey {
                result.insert(.init(x: a.x, y: y))
                result.insert(.init(x: b.x, y: y))
            }
        }
        
        return result
    }
}
