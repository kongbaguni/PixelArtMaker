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
    @Binding var drawBegainPointer:CGPoint?
    let pointer:CGPoint
    let backgroundColor:Color
    @State var isMiniDrawingMode:Bool = UserDefaults.standard.isMiniDrawingMode
    
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
        if StageManager.shared.canvasSize.isOut(cgPoint: target) {
            return
        }
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
                
                if cc.compare(color:colors[next.y][next.x]) <= UserDefaults.standard.paintRange || cc == colors[next.y][next.x] {
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
                if color.compare(color: cc) <= UserDefaults.standard.paintRange {
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
        /** 포인트 투 포인트 드로잉 도구*/
        case 드로잉
        case 박스선
        case 박스채우기
        case 동그라미
        case 취소
        case 미니토글
    }
    
    
    private func makeImageButton(imageName:String,action:@escaping()->Void) -> some View {
        Button {
            action()
        } label : {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
        }.frame(width: 50, height: 50, alignment: .center)
    }
    
    private func makeImageButton(systemName:String,action:@escaping()->Void) -> some View {
        Button {
            action()
        } label : {
            Image(systemName: systemName)
                .resizable()
                .imageScale(.large)
                .frame(width: 30, height: 30, alignment: .center)
                .padding(10)
                .foregroundColor(.gray)
        }

    }
    
    
    private func makeButton(type:ButtonType)-> some View {
        Group {
            switch type {
            case .돋보기:
                makeImageButton(systemName: isZoomMode ? "xmark.circle" : "plus.magnifyingglass") {
                    withAnimation(.easeInOut) {
                        isZoomMode.toggle()
                    }
                }

            case .연필:
                makeImageButton(imageName:"pencil") {
                    draw(target: pointer, color: forgroundColor)
                }
            case .페인트1:
                makeImageButton(imageName:"paint") {
                    paint(target: pointer, color: forgroundColor)
                }
            case .페인트2:
                makeImageButton(imageName:"paint2") {
                    changeColor(target: pointer, color: forgroundColor)
                }
            case .지우개:
                makeImageButton(imageName:"eraser") {
                    draw(target: pointer, color: .clear)
                }
            case .스포이드:
                makeImageButton(imageName:"spoid") {
                    if let color = StageManager.shared.stage?.selectedLayer.colors[Int(pointer.y)][Int(pointer.x)] {
                        forgroundColor = color
                    }
                }
            case .드로잉:
                makeImageButton(systemName:"line.diagonal") {
                    if drawBegainPointer == nil {
                        withAnimation(.easeInOut) {
                            drawBegainPointer = pointer
                        }
                        
                    } else {
                        draw(points: PathFinder.findLine(startCGPoint: drawBegainPointer!, endCGPoint: pointer))
                    }
                }
            case .박스선:
                makeImageButton(systemName: "square") {
                    draw(points: PathFinder.findSquare(a: drawBegainPointer!, b: pointer))
                }
            case .박스채우기:
                makeImageButton(systemName: "square.fill") {
                    draw(points: PathFinder.findSquare(a: drawBegainPointer!, b: pointer, isFill: true))
                }
                
            case .동그라미:
                makeImageButton(systemName: "circle") {
                    draw(points: PathFinder.findCircle(center: drawBegainPointer!, end: pointer))
                }

            case .취소:
                makeImageButton(systemName:"xmark.circle") {
                    withAnimation(.easeInOut) {
                        drawBegainPointer = nil
                    }
                }
            case .미니토글:
                makeImageButton(systemName: isMiniDrawingMode ? "chevron.forward" : "chevron.backward") {
                    withAnimation(.easeInOut) {
                        isMiniDrawingMode.toggle()
                        UserDefaults.standard.isMiniDrawingMode = isMiniDrawingMode
                    }
                }
            }
        
        }
    }
    
    private func draw(points:Set<PathFinder.Point>) {
        for point in points {
            if point.isIn(size: StageManager.shared.canvasSize) {
                colors[point.y][point.x] = forgroundColor
            }
        }
        refreshStage()
        withAnimation(.easeInOut) {
            drawBegainPointer = nil
        }
    }
    private let miniToolTypes:[ButtonType] = [.돋보기, .드로잉, .연필, .지우개, .스포이드, .미니토글]
    private let normalToolTypes:[ButtonType] = [.돋보기, .드로잉, .연필, .페인트1, .페인트2, .지우개, .스포이드, .미니토글]
    private let drawingToolTypes:[ButtonType] = [.취소, .돋보기, .드로잉, .동그라미, .박스선, .박스채우기]

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
                        ForEach(drawBegainPointer == nil
                                ? isMiniDrawingMode ? miniToolTypes : normalToolTypes
                                : drawingToolTypes, id:\.self) { type in
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

