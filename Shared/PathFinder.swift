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

struct PathFinder {
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
        
        var cgpoint:CGPoint {
            return .init(x: x, y: y)
        }
        
        func isIn(size:CGSize)->Bool {
            let p = cgpoint
            if p.x < 0 || p.y < 0 || p.x >= size.width || p.y >= size.width {
                return false
            }
            return true
        }
    }
        
    static func findLine(startCGPoint:CGPoint, endCGPoint:CGPoint)->Set<Point> {
        return findLine(startPosition: startCGPoint.pointValue, endPosition: endCGPoint.pointValue)
    }
    
    static func findLine(startPosition:Point, endPosition:Point)->Set<Point> {
        var result = Set<Point>()
        let width = abs(endPosition.x - startPosition.x)
        let height = abs(endPosition.y - startPosition.y)
        let Yfactor = endPosition.y < startPosition.y ? -1 : 1;
        let Xfactor = endPosition.x < startPosition.x ? -1 : 1;

        // 넓이가 높이보다 큰경우는 1,4,5,8 분면
        if width > height {
            var y = startPosition.y
            var det = (2 * height) - width; // 점화식
            
            var x = startPosition.x
            while x != endPosition.x {
                x += Xfactor
                //판별
                if (det < 0) {
                    det += 2 * height
                }
                else {
                    y += Yfactor
                    det += (2 * height - 2 * width)
                }
                
                result.insert(.init(x: x, y: y))
            }
        }
        else {
            var x = startPosition.x
            var det2 = (2 * width) - height; // 점화식
            var y = startPosition.y
            while y != endPosition.y {
                y += Yfactor
                if (det2 < 0) {
                    det2 += 2 * width
                }
                else {
                    x += Xfactor
                    det2 += (2 * width - 2 * height)
                }
                result.insert(.init(x: x, y: y))
            }
        }
        return result
    }
    
    static func findSquare(a:CGPoint, b:CGPoint, isFill:Bool = false)->Set<Point> {
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
    
    
    
    static func findCircle(center:CGPoint, end:CGPoint)->Set<Point> {
        var result = Set<Point>()
        let _iCenterX = Int(center.x)
        let _iCenterY = Int(center.y)
        let _iEndX = Int(end.x)
        let _iEndY = Int(end.y)
        let iDeltaX = _iEndX - _iCenterX
        let iDeltaY = _iEndY - _iCenterY
        
        
        let sum = (iDeltaX * iDeltaX) + (iDeltaY * iDeltaY)
        let iRadius = Int(sqrt(Double(sum)))
        
        var iX = 0
        var iY = iRadius
        var iD = 1 - iRadius                 // 결정변수를 int로 변환
        var iDeltaE = 3                     // E가 선택됐을 때 증분값
        var iDeltaSE = -2 * iRadius + 5     // SE가 선탣됐을 때 증분값
     
        result.insert(center.pointValue + Point(x: iX, y: iY))
        
        // 12시 방향에서 시작해서 시계방향으로 회전한다고 했을 때
        // 45도를 지나면 y값이 x값보다 작아지는걸 이용
        while (iY > iX) {
            // E 선택
            if (iD < 0)
            {
                iD += iDeltaE
                iDeltaE += 2
                iDeltaSE += 2
            }
            // SE 선택
            else
            {
                iD += iDeltaSE
                iDeltaE += 2
                iDeltaSE += 4
                iY -= 1;
            }
            iX += 1;
     
            result.insert(center.pointValue + Point(x: iX, y: iY))
        }        
        return result
    }
}
