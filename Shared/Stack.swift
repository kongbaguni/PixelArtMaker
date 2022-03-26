//
//  Stack.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import Foundation
struct Stack<T> {
    private var limit:Int? = nil
    
    private var stack: [T] = []
    
    public var count: Int {
        return stack.count
    }
    
    public var isEmpty: Bool {
        return stack.isEmpty
    }
    
    public mutating func push(_ element: T) {
        stack.append(element)
        if let l = limit {
            while stack.count > l {
                stack.removeFirst()
            }
        }
    }
    
    public mutating func pop() -> T? {
        return isEmpty ? nil : stack.popLast()
    }
    
    public mutating func removeAll() {
        stack.removeAll()
    }
    
    public var arrayValue:[T] {
        get {
            return stack
        }
    }
    
    public mutating func setLimit(_ limit:Int) {
        self.limit = limit
    }
    
}
