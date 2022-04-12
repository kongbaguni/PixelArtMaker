//
//  DrawingToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct DrawingToolView: View {
    struct Point : Hashable {
        public static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        init(point:CGPoint) {
            self.x = Int(point.x)
            self.y = Int(point.y)
        }
        init(x:Int, y:Int) {
            self.x = x
            self.y = y
        }
        let x:Int
        let y:Int
    }
    
    @Binding var isZoomMode:Bool
    @Binding var colors:[[Color]]
    @Binding var forgroundColor:Color
    @Binding var undoCount:Int
    @Binding var redoCount:Int
    @Binding var toastMessage:String
    @Binding var isShowToast:Bool
    @Binding var previewImage:Image?
    let pointer:CGPoint
    let backgroundColor:Color
    
    
    func erase(target:CGPoint) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        erase(idx: idx)
    }
    
    func erase(idx:(Int,Int)) {
        draw(idx: idx, color: .clear)
    }
    
    
    func paint(target:CGPoint, color:Color) {
        let idx:Point = .init(point: target)
        /** 최초 선택 컬러*/
        let cc = colors[idx.y][idx.x]
        
        func getNextIdxs(idx:Point)->Set<Point> {
            var nextIdxs:[Point] {
                return [
                    .init(x: idx.x, y: idx.y+1),
                    .init(x: idx.x, y: idx.y-1),
                    .init(x: idx.x+1, y: idx.y),
                    .init(x: idx.x-1, y: idx.y),
                ]
            }
            var result = Set<Point>()
            for next in nextIdxs {
                if next.x < 0 || next.y < 0 || next.y >= colors.count || next.x >= colors[0].count {
                    continue
                }
                if colors[next.y][next.x] == cc {
                    result.insert(next)
                }
            }
            return result
        }
        
        var list = getNextIdxs(idx: idx)
        var test = true
        while test {
            let count = list.count
            for idx in list {
                for new in getNextIdxs(idx: idx) {
                    list.insert(new)
                }
            }
            if count == list.count {
                test = false
            }
        }
        colors[idx.y][idx.x] = color
        for i in list {
            colors[i.y][i.x] = color
        }
        refreshStage()
    }
    
    func draw(target:CGPoint, color: Color) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        draw(idx: idx, color: color)
    }
    
    func draw(idx:(Int,Int), color:Color) {
        if idx.0 < colors.count && idx.0 >= 0 {
            if idx.1 < colors[idx.0].count && idx.1 >= 0 {
                colors[idx.1][idx.0] = color
            }
        }
        refreshStage()
    }
    
    func changeColor(target:CGPoint, color:Color) {
        let idx:Point = .init(point: target)
        /** 최초 선택 컬러*/
        var result = Set<Point>()
        let cc = colors[idx.y][idx.x]
        for (i,list) in colors.enumerated() {
            for (r,color) in list.enumerated() {
                if cc == color {
                    result.insert(.init(x: r, y: i))
                }
            }
        }
        
        for point in result {
            colors[point.y][point.x] = color
        }
        refreshStage()
    }
    
    
    
    private func refreshStage() {
        StageManager.shared.stage?.change(colors: colors)
        StageManager.shared.stage?.backgroundColor = backgroundColor
        StageManager.shared.stage?.forgroundColor = forgroundColor
        if let stage = StageManager.shared.stage {
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
        }
        StageManager.shared.saveTemp { error in
            if let err = error {
                toastMessage = err.localizedDescription
                isShowToast = true
            } else {
                StageManager.shared.stage?.getImage(size: Consts.previewImageSize, complete: { image in
                    previewImage = image
                })
            }
        }
    }
    
    private enum ButtonType : CaseIterable {
        case 돋보기
        case 연필
        case 페인트1
        case 페인트2
        case 지우개
        case 스포이드
    }
    private func makeButton(type:ButtonType)-> some View {
        Group {
            switch type {
            case .돋보기:
                Button {
                    withAnimation {
                        isZoomMode.toggle()
                    }
                } label : {
                    Image(systemName: "plus.magnifyingglass")
                        .resizable()
                        .opacity(isZoomMode ? 1.0 : 0.2)
                        .imageScale(.large)
                        .frame(width: 50, height: 50, alignment: .center)
                        .padding(isZoomMode ? 10 : 0)
                        .foregroundColor(.gray)
                }
            case .연필:
                Button {
                } label : {
                    Image("pencil")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                    
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                        draw(target: pointer, color: forgroundColor)
                    }))
            case .페인트1:
                Button {
                } label : {
                    Image("paint")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                        paint(target: pointer, color: forgroundColor)
                    }))
            case .페인트2:
                Button {
                } label : {
                    Image("paint2")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                        changeColor(target: pointer, color: forgroundColor)
                    }))
            case .지우개:
                Button {
                } label : {
                    Image("eraser")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                        .background(.clear)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                        draw(target: pointer, color: .clear)
                    }))
            case .스포이드:
                Button {
                } label : {
                    Image("spoid")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                        .background(.clear)
                }.frame(width: 50, height: 50, alignment: .center)
                    .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                        if let color = StageManager.shared.stage?.selectedLayer.colors[Int(pointer.y)][Int(pointer.x)] {
                            forgroundColor = color
                        }
                    }))
            }
        }
    }
    
    var body: some View {
        Group {
            if isZoomMode {
                HStack {
                    Spacer()
                    makeButton(type: .돋보기)
                    Spacer()
                }
                
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(ButtonType.allCases, id:\.self) { type in
                            makeButton(type: type)
                        }
                    }
                    .padding(5)
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .layerblendModeDidChange, object: nil, queue: nil) { noti in
                refreshStage()
            }
        }
        
    }
}

