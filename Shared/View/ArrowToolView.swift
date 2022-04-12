//
//  ArrowToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI
extension Notification.Name {
    static let zoomOffsetDidChanged = Notification.Name("zoomOffsetDidChanged_observer")
}

struct ArrowToolView: View {
    @Binding var isZoomMode:Bool
    @Binding var toastMessage:String
    @Binding var isShowToast:Bool
    @Binding var isLongPressing:Bool
    @Binding var timer:Timer?
    @Binding var pointer:CGPoint
    @Binding var zoomOffset:(x:Int,y:Int)
    @Binding var zoomScale:Int
    let zoomFrame:(width:Int,height:Int)
    let isShowMenu:Bool
    let redoCount:Int
    let undoCount:Int
    
    var zoomLimit:Int {
        (Int(StageManager.shared.canvasSize.width)/2) - 8
    }
    
    private enum ButtonType : Int {
        case up
        case down
        case left
        case right
        case zoomIn
        case zoomOut
        case undo
        case redo
    }
    
    private enum ZoomDirection {
        case zoomIn
        case zoomOut
    }
    
    private enum MoveDirection : Int{
        case up
        case down
        case left
        case right
    }
    
    private func timerReset() {
        isLongPressing = false
        timer?.invalidate()
    }
    
    private func movePointer(direction:MoveDirection) {
        switch direction {
        case .up:
            pointer.y -= 1
            if pointer.y < 0 {
                pointer.y = 0
                timerReset()
            }
        case .down:
            pointer.y += 1
            let heightLimit = StageManager.shared.canvasSize.height
            if pointer.y > heightLimit {
                pointer.y = heightLimit
                timerReset()
            }
        case .left:
            pointer.x -= 1
            if pointer.x < 0 {
                pointer.x = 0
                timerReset()
            }
            
        case .right:
            pointer.x += 1
            let widthLimit = StageManager.shared.canvasSize.width
            if pointer.x > widthLimit {
                pointer.x = widthLimit
                timerReset()
            }
        }
    }
    
    private func move(directipn:MoveDirection) {
        switch directipn {
        case .left:
            var nx = zoomOffset.x - 1
            if nx < 0 {
                nx = 0
            }
            zoomOffset.x = nx
        case .up:
            var ny = zoomOffset.y - 1
            if ny < 0 {
                ny = 0
            }
            zoomOffset.y = ny
        case .down:
            var ny = zoomOffset.y + 1
            let ph = Int(StageManager.shared.canvasSize.height)
            let h = ph - zoomScale * 2
            if ny + h > ph {
                ny = ph - h
            }
            zoomOffset.y = ny
            
        case .right:
            var nx = zoomOffset.x + 1
            let pw = Int(StageManager.shared.canvasSize.width)
            let w = pw - zoomScale * 2
            if nx + w > pw {
                nx = pw - w
            }
            zoomOffset.x = nx
        }
        
        var frameSize:(width:Int,height:Int) {
            let size = StageManager.shared.canvasSize
            let ow = Int(size.width)
            let oh = Int(size.height)
            return (width:ow - zoomScale * 2, height:oh - zoomScale * 2)
        }
        
        
        while zoomOffset.x + frameSize.width > Int(StageManager.shared.canvasSize.width) {
            zoomOffset.x -= 1
        }
        
        while zoomOffset.y + frameSize.height > Int(StageManager.shared.canvasSize.height) {
            zoomOffset.y -= 1
        }
                            
        notifiZoomOffset()
    }
    
    
    private func zoom(direction:ZoomDirection) {
        switch direction {
        case .zoomIn:
            zoomScale += 1
            if zoomScale > zoomLimit {
                zoomScale = zoomLimit
                timerReset()
                return
            }
            move(directipn: .right)
            move(directipn: .down)
        case .zoomOut:
            zoomScale -= 1
            if zoomScale < 0 {
                zoomScale = 0
                timerReset()
            }
            move(directipn: .up)
            move(directipn: .left)
        }
        notifiZoomOffset()
    }

    private func notifiZoomOffset() {
        NotificationCenter.default.post(name: .zoomOffsetDidChanged, object: nil, userInfo: [
            "offset":zoomOffset,
            "scale":zoomScale
        ])
    }
    
    private func getImageName(type:ButtonType)->String {
        switch type {
        case .up, .zoomIn:
            return "arrow_up"
        case .down, .zoomOut:
            return "arrow_down"
        case .left:
            return "arrow_left"
        case .right:
            return "arrow_right"
        default:
            return "none"
        }
    }
    
    private func makeImage(type:ButtonType)-> some View {
        Image(getImageName(type: type))
            .resizable()
            .frame(width: 50, height: 50, alignment: .center)
    }
    
    private func makeArrowButton(direction:MoveDirection?)->some View {
        Button {
            if isLongPressing {
                isLongPressing = false
                timer?.invalidate()
                timer = nil
            }

            if let d = direction {
                if isZoomMode {
                    move(directipn: d)
                } else {
                    movePointer(direction: d)
                }
            }
        } label: {
            makeImage(type: ButtonType(rawValue: direction?.rawValue ?? 0) ?? .up)
        }
        .frame(width: 50, height: 50, alignment: .center)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                print("long press")
                self.isLongPressing = true
                //or fastforward has started to start the timer
                if let t = timer {
                    t.invalidate()
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                    if let d = direction {
                        if isZoomMode {
                            move(directipn: d)
                        } else {
                            movePointer(direction: d)
                        }
                    }
                })
            }
        )
    }
    
    private func makeZoomButton(zoomType:ZoomDirection)-> some View {
        Button {
            if isLongPressing {
                isLongPressing = false
                timer?.invalidate()
                timer = nil
            }

            zoom(direction: zoomType)
        } label : {
            switch zoomType {
            case .zoomIn:
                makeImage(type: .zoomIn)
            case .zoomOut:
                makeImage(type: .zoomOut)
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                print("long press")
                self.isLongPressing = true
                if let t = timer {
                    t.invalidate()
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                    zoom(direction: zoomType)
                })
            }
        )
    }
    
    private func makeButton(type:ButtonType)-> some View {
        
        Group {
            switch type {
            case .undo:
                //MARK: - undo
                Button {
                    if isShowMenu {
                        return
                    }
                    StageManager.shared.stage?.undo()
                    StageManager.shared.saveTemp { error in
                        toastMessage = error?.localizedDescription ?? ""
                        isShowToast = error != nil
                    }
                } label: {
                    VStack {
                        Image(systemName:"arrow.uturn.backward.circle")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                        if redoCount + undoCount > 0 {
                            ProgressView(value: CGFloat(undoCount) / CGFloat(redoCount + undoCount) )
                                .frame(width: 50, height: 5, alignment: .center)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView(value: 0)
                                .frame(width: 50, height: 5, alignment: .center)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 50, height: 50, alignment: .center)
                .padding(20)
            case .redo:
                //MARK: - redo
                Button {
                    StageManager.shared.stage?.redo()
                    StageManager.shared.saveTemp { error in
                        toastMessage = error?.localizedDescription ?? ""
                        isShowToast = error != nil
                    }
                    
                } label: {
                    VStack {
                        Image(systemName:"arrow.uturn.forward.circle").imageScale(.large)
                            .foregroundColor(.gray)
                        if redoCount + undoCount > 0 {
                            ProgressView(value: CGFloat(redoCount) / CGFloat(redoCount + undoCount) )
                                .frame(width: 50, height: 5, alignment: .center)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView(value: 0)
                                .frame(width: 50, height: 5, alignment: .center)
                                .foregroundColor(.gray)
                            
                        }
                    }
                }
                .frame(width: 50, height: 50, alignment: .center)
                .padding(20)
            case .left:
                makeArrowButton(direction: .left)
            case .up:
                makeArrowButton(direction: .up)
            case .down:
                makeArrowButton(direction: .down)
            case .right:
                makeArrowButton(direction: .right)
                
            case .zoomIn:
                makeZoomButton(zoomType: .zoomIn)
            case .zoomOut:
                makeZoomButton(zoomType: .zoomOut)
            }
        }
    }
    
    var body: some View {
        HStack(alignment:.center) {
            Spacer()
            Group{
                if !isZoomMode {
                    //MARK: - undo
                    makeButton(type: .undo)
                }
                else {
                    VStack {
                        makeButton(type: .zoomIn)
                        makeButton(type: .zoomOut)
                    }
                }
                
                makeButton(type: .left)
                
                VStack {
                    makeButton(type: .up)
                    makeButton(type: .down)
                }
                makeButton(type: .right)
                
                if !isZoomMode {
                    makeButton(type: .redo)
                }
            }
            Spacer()
        }
    }
}

