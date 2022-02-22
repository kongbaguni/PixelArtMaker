//
//  KeyEventHandling.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/08.
//

import SwiftUI
struct KeyEventHandling: NSViewRepresentable {
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            print(">> key \(event.charactersIgnoringModifiers ?? "")")
            
            if let char = event.charactersIgnoringModifiers {
//                Calculator.shared.keyInput(key: char)
                print(char.asciiValues)
                
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        
    }
}
