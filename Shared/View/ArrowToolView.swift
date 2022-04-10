//
//  ArrowToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct ArrowToolView: View {
    @Binding var zoomMode:PixelDrawView.ZoomMode
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
    
    var body: some View {
        HStack {
            if zoomMode == .none {
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
                        Image(systemName:"arrow.uturn.backward.circle").imageScale(.large)
                        if redoCount + undoCount > 0 {
                            ProgressView(value: CGFloat(undoCount) / CGFloat(redoCount + undoCount) )
                                .frame(width: 50, height: 5, alignment: .center)
                        } else {
                            ProgressView(value: 0)
                                .frame(width: 50, height: 5, alignment: .center)
                        }
                    }
                }
                .frame(width: 50, height: 50, alignment: .center)
                .padding(20)
            }
            
            //MARK: - 왼쪽
            Button {
                switch zoomMode {
                case .none:
                    if isLongPressing {
                        isLongPressing = false
                        timer?.invalidate()
                    }
                    pointer = .init(x: pointer.x - 1, y: pointer.y)

                case .zoom:
                    break
                case .offset:
                    var nx = zoomOffset.x - 1
                    if nx < 0 {
                        nx = 0
                    }
                    zoomOffset.x = nx
                }
                
            } label: {
                Image("arrow_left")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .opacity(zoomMode == .zoom ? 0.2 : 1.0)
            .frame(width: 50, height: 50, alignment: .center)
            .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                        if zoomMode != .none {
                            return
                        }
                        print("long press")
                        self.isLongPressing = true
                        //or fastforward has started to start the timer
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                            pointer = .init(x: pointer.x - 1, y: pointer.y)
                        })
                    }
                )
            
            VStack {
                //MARK: - 위로
                Button {
                    switch zoomMode {
                    case .none:
                        if isLongPressing {
                            isLongPressing = false
                            timer?.invalidate()
                        }
                        pointer = .init(x: pointer.x, y: pointer.y - 1)

                    case .zoom:
                        zoomScale += 1
                        if zoomScale > zoomLimit {
                            zoomScale = zoomLimit
                        }
                    case .offset:
                        var ny = zoomOffset.y - 1
                        if ny < 0 {
                            ny = 0
                        }
                        zoomOffset.y = ny
                    }
                } label: {
                    Image("arrow_up")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            if zoomMode != .none {
                                return
                            }
                            print("long press")
                            self.isLongPressing = true
                            //or fastforward has started to start the timer
                            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                pointer = .init(x: pointer.x, y: pointer.y - 1)
                            })
                        }
                    )
                //MARK: - 아래로
                Button {
                    switch zoomMode {
                    case .none:
                        if isLongPressing {
                            isLongPressing = false
                            timer?.invalidate()
                        }
                        pointer = .init(x: pointer.x, y: pointer.y + 1)

                    case .zoom:
                        zoomScale -= 1
                        if zoomScale < 0 {
                            zoomScale = 0
                        }
                        if zoomOffset.x > 2 {
                            zoomOffset.x -= 2
                        }
                        else if zoomOffset.x > 0 {
                            zoomOffset.x -= 1
                        }
                        
                        if zoomOffset.y > 2 {
                            zoomOffset.y -= 2
                        }
                        else if zoomOffset.y > 0 {
                            zoomOffset.y -= 1
                        }
                        
                    case .offset:
                        var ny = zoomOffset.y + 1
                        let ph = Int(StageManager.shared.canvasSize.height)
                        let h = ph - zoomScale * 2
                        if ny + h > ph {
                            ny = ph - h
                        }
                        zoomOffset.y = ny
                    }
                } label: {
                    Image("arrow_down")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            if zoomMode != .none {
                                return
                            }
                            print("long press")
                            self.isLongPressing = true
                            //or fastforward has started to start the timer
                            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                pointer = .init(x: pointer.x, y: pointer.y + 1)
                            })
                        }
                    )
            }
            //MARK: - 오른쪽
            Button {
                switch zoomMode {
                case .none:
                    if isLongPressing {
                        isLongPressing = false
                        timer?.invalidate()
                    }
                    pointer = .init(x: pointer.x + 1, y: pointer.y)
                case .zoom:
                    break
                case .offset:
                    var nx = zoomOffset.x + 1
                    let pw = Int(StageManager.shared.canvasSize.width)
                    let w = pw - zoomScale * 2
                    if nx + w > pw {
                        nx = pw - w
                    }
                    zoomOffset.x = nx
                }
            } label: {
                Image("arrow_right")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .opacity(zoomMode == .zoom ? 0.2 : 1.0 )
            .frame(width: 50, height: 50, alignment: .center)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                        if zoomMode != .none {
                            return
                        }
                        print("long press")
                        self.isLongPressing = true
                        //or fastforward has started to start the timer
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                            pointer = .init(x: pointer.x + 1, y: pointer.y)
                        })
                    }
                )
            if zoomMode == .none {
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
                        if redoCount + undoCount > 0 {
                            ProgressView(value: CGFloat(redoCount) / CGFloat(redoCount + undoCount) )
                                .frame(width: 50, height: 5, alignment: .center)
                        } else {
                            ProgressView(value: 0)
                                .frame(width: 50, height: 5, alignment: .center)
                            
                        }
                    }
                }
                .frame(width: 50, height: 50, alignment: .center)
                .padding(20)
            }
        }
    }
}

