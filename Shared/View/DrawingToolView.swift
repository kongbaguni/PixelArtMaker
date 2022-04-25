//
//  DrawingToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct DrawingToolView: View {
    
    @Binding var isZoomMode:Bool
    @Binding var colors:[[Color]]
    @Binding var forgroundColor:Color
    @Binding var backgroundColor:Color
    @Binding var undoCount:Int
    @Binding var redoCount:Int
    @Binding var toastMessage:String
    @Binding var isShowToast:Bool
    @Binding var previewImage:Image?
    @Binding var drawBegainPointer:CGPoint?
    /** 광범위 페인팅 시도할 때 드로잉 툴 잠그기 위한 flag*/
    @State var isBegainPainting = false
    let colorSelectMode:PaletteView.ColorSelectMode
    let pointer:CGPoint
    @State var isMiniDrawingMode:Bool = UserDefaults.standard.isMiniDrawingMode
    
    func erase(target:CGPoint) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        erase(idx: idx)
    }
    
    func erase(idx:(Int,Int)) {
        draw(idx: idx, color: .clear)
    }
    
    
    func paint(target:CGPoint, color:Color) {
        var changeSet = Set<ColorChangeModelWithLayerPoint>()
        
        let idx:PathFinder.Point = .init(point: target)
        /** 최초 선택 컬러*/
        if StageManager.shared.canvasSize.isOut(cgPoint: target) {
            return
        }
        let cc = colors[idx.y][idx.x]
        
        func getNextIdxs(idx:PathFinder.Point)->Set<PathFinder.Point> {
            var nextIdxs:[PathFinder.Point] {
                return [
                    .init(x: idx.x, y: idx.y+1),
                    .init(x: idx.x, y: idx.y-1),
                    .init(x: idx.x+1, y: idx.y),
                    .init(x: idx.x-1, y: idx.y),
                ]
            }
            var result = Set<PathFinder.Point>()
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
        let layerIndex = StageManager.shared.stage!.selectedLayerIndex
        for i in list {
            let old = colors[i.y][i.x]
            colors[i.y][i.x] = color
            changeSet.insert(.init(layerIndex: layerIndex, point: .init(x: i.x, y: i.y), change: .init(before: old, after: color)))
        }
        HistoryManager.shared.addHistory(.init(colorChanges: changeSet))
        refreshStage()
    }
    
    func draw(target:CGPoint, color: Color) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        draw(idx: idx, color: color)
    }
    
    func draw(idx:(Int,Int), color:Color) {
        
        if PathFinder.Point(x: idx.0, y: idx.1).isIn(size: StageManager.shared.canvasSize) {
            let before = colors[idx.1][idx.0]
            colors[idx.1][idx.0] = color
            var set = Set<ColorChangeModelWithLayerPoint>()
            set.insert(.init(layerIndex: StageManager.shared.stage!.selectedLayerIndex ,
                                           point: .init(x: idx.0, y: idx.1), change: .init(before: before, after: color)))
            HistoryManager.shared.addHistory(.init(colorChanges: set))
            refreshStage()
        }
        
    }
    
    func changeColor(target:CGPoint, color:Color) {
        var changeSet = Set<ColorChangeModelWithLayerPoint>()
        
        if StageManager.shared.canvasSize.isOut(cgPoint: target) {
            return
        }
        let idx:PathFinder.Point = .init(point: target)
        /** 최초 선택 컬러*/
        var result = Set<PathFinder.Point>()
        let cc = colors[idx.y][idx.x]
        for (i,list) in colors.enumerated() {
            for (r,color) in list.enumerated() {
                if color.compare(color: cc) <= UserDefaults.standard.paintRange {
                    result.insert(.init(x: r, y: i))
                }
            }
        }
        
        for point in result {
            let old = colors[point.y][point.x]
            colors[point.y][point.x] = color
            changeSet.insert(.init(layerIndex: StageManager.shared.stage!.selectedLayerIndex,
                                   point: point,
                                   change: .init(before: old, after: color)))
        }
        HistoryManager.shared.addHistory(.init(colorChanges: changeSet))
        refreshStage()

    }
    
    func spoid(target:CGPoint) {
        if StageManager.shared.canvasSize.isOut(cgPoint: pointer) == false {
            let idx = PathFinder.Point(point: pointer)
            if let color = StageManager.shared.stage?.selectedLayer.colors[idx.y][idx.x] {
                switch colorSelectMode {
                case .foreground:
                    forgroundColor = color
                case .background:
                    backgroundColor = color
                }
            }
        }
    }
    
    private func refreshStage() {
        StageManager.shared.stage?.change(colors: colors)
        StageManager.shared.stage?.backgroundColor = backgroundColor
        StageManager.shared.stage?.forgroundColor = forgroundColor

        undoCount = HistoryManager.shared.undoCount
        redoCount = HistoryManager.shared.redoCount

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
                    if isBegainPainting {
                        return
                    }
                    draw(target: pointer, color: forgroundColor)
                }.opacity(isBegainPainting ? 0.2 : 1.0)
                
            case .페인트1:
                makeImageButton(imageName:"paint") {
                    if isBegainPainting {
                        return
                    }
                    isBegainPainting = true
                    DispatchQueue.global().async {
                        paint(target: pointer, color: forgroundColor)
                        isBegainPainting = false
                    }
                }.opacity(isBegainPainting ? 0.2 : 1.0)
                
            case .페인트2:
                makeImageButton(imageName:"paint2") {
                    if isBegainPainting {
                        return
                    }
                    changeColor(target: pointer, color: forgroundColor)
                }.opacity(isBegainPainting ? 0.2 : 1.0)
                
            case .지우개:
                makeImageButton(imageName:"eraser") {
                    if isBegainPainting {
                        return
                    }
                    draw(target: pointer, color: .clear)
                }.opacity(isBegainPainting ? 0.2 : 1.0)
                
            case .스포이드:
                makeImageButton(imageName:"spoid") {
                    spoid(target: pointer)
                }
            case .드로잉:
                makeImageButton(systemName:"line.diagonal") {
                    if isBegainPainting {
                        return
                    }
                    if drawBegainPointer == nil {
                        withAnimation(.easeInOut) {
                            drawBegainPointer = pointer
                        }
                        
                    } else {
                        draw(points: PathFinder.findLine(startCGPoint: drawBegainPointer!, endCGPoint: pointer))
                    }
                }.opacity(isBegainPainting ? 0.2 : 1.0)
                
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
        var cset = Set<ColorChangeModelWithLayerPoint>()
        
        for point in points {
            if point.isIn(size: StageManager.shared.canvasSize) {
                let old = colors[point.y][point.x]
                colors[point.y][point.x] = forgroundColor
                cset.insert(.init(layerIndex: StageManager.shared.stage!.selectedLayerIndex,
                                  point: point,
                                  change: .init(before: old, after: forgroundColor)))
            }
        }
        HistoryManager.shared.addHistory(.init(colorChanges: cset))
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

