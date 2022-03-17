//
//  Stack.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import Foundation
struct Stack<T> {
    private var stack: [T] = []
    
    public var count: Int {
        return stack.count
    }
    
    public var isEmpty: Bool {
        return stack.isEmpty
    }
    
    public mutating func push(_ element: T) {
        stack.append(element)
    }
    
    public mutating func pop() -> T? {
        return isEmpty ? nil : stack.popLast()
    }
    
    public mutating func removeAll() {
        stack.removeAll()
    }
}
