//
//  ContentView.swift
//  Ribbon
//
//  Created by Jessica Linden on 12/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var center: CGFloat = 350
    @State private var range: CGFloat = 0
    @State private var previousRange: CGFloat = 200
    @State private var ribbonState: RibbonState = .closed
    @State private var scaleEffect: CGFloat = 1
    @State private var removeAnimation = false
    
    @GestureState private var selectedHandle: HandleType?
    @GestureState private var previousLocation: CGFloat?
    @GestureState private var dragBeganInsideRange: Bool?
    
    private var ribbon: Ribbon {
        Ribbon(center: center, range: range) }
    private let anchorPoints: [RibbonAnchorPoint] = RibbonAnchorPoint.defaults
    private var contracted: Bool { range == 0 }
    private var offset: CGFloat { center - halfRange }
    private let practicalZero: CGFloat = 5
    private var halfRange: CGFloat { range / 2 }
    private var minCenterBoundary: CGFloat { halfRange }
    private var maxCenterBoundary: CGFloat { width - halfRange }
    private let gradient = LinearGradient(colors: [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple], startPoint: .leading, endPoint: .trailing)
    private let width: CGFloat = 700
    private let totalHeight: CGFloat = 70
    private var rectangleHeight: CGFloat { totalHeight * 0.9 }
    private let triangleWidth: CGFloat = 15
    private var trianglePosition: CGFloat { offset + halfRange }
    private let handleWidth: CGFloat = 12
    private var handleHeight: CGFloat { totalHeight }
    private var handleOpacity: CGFloat {
        let adjustedPracticalZero = selectedHandle == nil ? 0 : practicalZero / width
        let adjustedRangeFactor = range * 20
        return min(max(adjustedPracticalZero, adjustedRangeFactor), 1.0)
    }
    private let wellSize = 0.02
    private var halfWell: CGFloat { wellSize / 2 }

    var body: some View {
        ZStack {
            insideView
            
            TwoSidedView(visibleSide: ribbonState.visibleSide,
                         front: {
                ribbonView
                    .background()
                    .gesture(tap.sequenced(before: doubleTap).exclusively(before: openDoorPress))
                    .gesture(anchorDrag.simultaneously(with: simpleDrag))
            }, back: {
                backsideView
                    .onTapGesture {
                        ribbonState.toggle()
                    }
            })
            .animation(removeAnimation ? nil : .smooth(duration: 0.4), value: ribbon)
            .animation(ribbonState == .closed ? .smooth(duration: 0.4) : .interpolatingSpring(.snappy(duration: 0.8, extraBounce: 0.5)), value: ribbonState)
        }
        .frame(width: width, height: rectangleHeight)
        .scaleEffect(scaleEffect)
    }
}

private extension ContentView {
    struct Ribbon: Equatable {
        var center: CGFloat
        var range: CGFloat
        
        static func ~=(lhs: Ribbon, rhs: Ribbon) -> Bool {
            lhs.center == rhs.center && lhs.range == rhs.range
        }
    }
    
    struct Handle: View {
        let color: Color
        
        init(color: Color = .white) {
            self.color = color
        }
        var body: some View {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 3)
                )
        }
    }
    
    enum HandleType {
        case leading, trailing
    }
    
    enum RibbonAnchorPoint {
        case center
        // additional cases if desired
        
        static var defaults: [Self] { [.center] }
        
        var point: CGFloat {
            switch self {
            case .center: 0.5
            }
        }
    }
    
    enum RibbonState {
        case closed, open
        
        var visibleSide: TwoSidedSelection {
            switch self {
            case .open: .back
            case .closed: .front
            }
        }
        
        mutating func toggle() {
            self = self == .open ? .closed : .open
        }
    }
}

private extension ContentView { // views
    var ribbonView: some View {
        ZStack(alignment: .leading) {
            Group {
                baseRibbon
                selector
            }
            .frame(height: rectangleHeight)
            
            leadingHandle
            trailingHandle
            triangle
        }
        .frame(width: width, height: totalHeight)
    }
    
    var baseRibbon: some View {
        gradient
            .opacity(0.4)
    }
    
    var selector: some View {
        gradient
            .mask(alignment: .leading) {
                Rectangle()
                    .frame(width: contracted ? practicalZero : range)
                    .offset(x: contracted ? center - (practicalZero / 2) : center - (range / 2))
            }
    }
    
    var triangle: some View {
        Triangle()
            .stroke(.black)
            .overlay(
                Triangle()
                    .fill(.white)
            )
            .frame(width: triangleWidth, height: triangleWidth)
            .rotationEffect(.degrees(180))
            .position(x: center, y: triangleWidth / 4)
    }
    
    var leadingHandle: some View {
        Handle()
            .frame(width: handleWidth, height: handleHeight)
            .position(x: center - halfRange - handleWidth / 2, y: handleHeight / 2)
            .opacity(handleOpacity)
            .gesture(rangeAdjustment(handle: .leading))
    }
    
    var trailingHandle: some View {
        Handle()
            .frame(width: handleWidth, height: handleHeight)
            .position(x: center + halfRange + handleWidth / 2, y: handleHeight / 2)
            .opacity(handleOpacity)
            .gesture(rangeAdjustment(handle: .trailing))
    }
    
    var insideView: some View {
        Image(.puppies)
            .resizable()
            .padding(8)
            .border(.white, width: 2)
            .frame(width: width, height: rectangleHeight)
            .overlay(alignment: .bottom) {
                hinges
            }
    }
    
    var backsideView: some View {
        Color.black
            .border(.white, width: 2)
            .overlay(
                Text("💛 THE DOOR'S OPEN! 💛").font(.title))
            .rotationEffect(.degrees(180))
            .background {
                Triangle()
                    .stroke(.black)
                    .frame(width: triangleWidth, height: triangleWidth)
                    .overlay(
                        Triangle()
                            .fill(.gray)
                    )
                    .frame(width: triangleWidth)
                    .rotationEffect(.degrees(180))
                    .position(x: width - trianglePosition)
            }
            .background {
                let leftHandlePosition = offset == 0 ? width : width - offset + (handleWidth / 2)
                Handle(color: .gray)
                    .frame(width: handleWidth, height: handleHeight + 5)
                    .position(x: leftHandlePosition, y: handleHeight / 2 - 5)
                    .opacity(contracted ? 0 : 1)
            }
            .background {
                let rightHandlePosition = offset == width - range ? 0 : width - (offset + range) - (handleWidth / 2)
                Handle(color: .gray)
                    .frame(width: handleWidth, height: handleHeight + 5)
                    .position(x: rightHandlePosition, y: handleHeight / 2 - 5)
                    .opacity(contracted ? 0 : 1)
            }
    }
    
    var hinges: some View {
        HStack {
            Spacer()
            Rectangle().frame(width: 10, height: 1)
            Spacer()
            Spacer()
            Rectangle().frame(width: 10, height: 1)
            Spacer()
            Spacer()
            Rectangle().frame(width: 10, height: 1)
            Spacer()
        }
        .offset(y: 2)
    }
}

private extension ContentView { // gestures
    var tap: some Gesture {
        SpatialTapGesture()
            .onEnded { tap in
                center = clamp(tap.location.x)
            }
    }
    
    var doubleTap: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { tap in
                if contracted {
                    if previousRange == 0 {
                        range = 0.4
                        previousRange = range
                    } else {
                        range = previousRange
                    }
                } else {
                    range = 0
                }
                
                center = clamp(tap.location.x)
            }
    }
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if let dragBeganInsideRange {
                    if let previousLocation {
                        let dragProgress = value.location.x - previousLocation
                        if dragBeganInsideRange { // drag proportional to finger movement
                            center += dragProgress
                        } else { // align the center with the finger
                            center = value.location.x
                        }
                    }
                }
                
                center = clamp(center)
            }
            .updating($dragBeganInsideRange) { (value, dragBeganInsideRange, _) in
                dragBeganInsideRange = dragBeganInsideRange ??
                (value.startLocation.x > center - halfRange && value.startLocation.x < center + halfRange)
            }
            .updating($previousLocation) { (value, previousLocation, _) in
                if previousLocation == nil {
                    previousLocation = value.startLocation.x
                } else {
                    previousLocation = value.location.x
                }
            }
    }
    
    var anchorDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                anchorPoints.forEach { anchor in
                    let leadingBoundary = width * (anchor.point - halfWell)
                    let trailingBoundary = width * (anchor.point + halfWell)
                    if contracted {
                        if value.location.x > leadingBoundary &&
                            value.location.x < trailingBoundary {
                            center = anchor.point * width
                            removeAnimation = true
                        } else {
                            removeAnimation = false
                        }
                    } else {
                        let difference = value.location.x - center
                        let adjustedLeading = leadingBoundary + difference
                        let adjustedTrailing = trailingBoundary + difference
                        
                        if value.location.x > adjustedLeading &&
                            value.location.x < adjustedTrailing {
                            center = anchor.point * width
                            removeAnimation = true
                        } else {
                            removeAnimation = false
                        }
                    }
                }
            }
    }
    
    var handleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                adjustTheRange(fingerLocation: value.location.x)
            }
            .onEnded { _ in
                previousRange = max(range, practicalZero)
            }
    }
    
    var handlePress: some Gesture {
        LongPressGesture(minimumDuration: 0)
    }
    
    func rangeAdjustment(handle: HandleType) -> some Gesture {
        SequenceGesture(handlePress, handleDrag)
            .updating($selectedHandle) { (_, selectedHandle, _) in
                selectedHandle = handle
            }
    }
    
    var openDoorPress: some Gesture {
        LongPressReleaseDetectionGesture(
            maxX: width,
            maxY: rectangleHeight,
            pressingState: { pressingState in
                withAnimation(.easeOut(duration: pressingState == .pressed ? 0.5 : 0.3)) {
                    
                    if pressingState == .pressed {
                        scaleEffect = 0.95
                    } else {
                        scaleEffect = 1
                        
                        if pressingState == .success {
                            ribbonState.toggle()
                        }
                    }
                }
            })
    }
    
    func adjustTheRange(fingerLocation: CGFloat) {
        if selectedHandle == .leading {
            let difference = fingerLocation - offset
            if offset + difference > 0 {
                guard (offset + range) - difference < width  else { // pin selector to trailing edge
                    center = maxCenterBoundary
                    range -= difference
                    return }
                
                // move toward leading edge
                range -= difference
                
            } else { // pin selector to leading edge
                center = minCenterBoundary
            }
        } else if selectedHandle == .trailing {
            let difference = fingerLocation - (offset + range)
            
            if offset + range + difference < width {
                guard offset - difference > 0 else { // pin selector to leading edge
                    center = minCenterBoundary
                    range += difference
                    return }
                
                // move toward trailing edge
                range += difference
            } else { // pin selector to trailing edge
                center = maxCenterBoundary
            }
        }
        
        guard range > practicalZero else {
            range = 0
            return }
    }
    
    func clamp(_ value: CGFloat) -> CGFloat {
        min(max(minCenterBoundary, value), maxCenterBoundary)
    }
}

#Preview("Ribbon", traits: .landscapeRight) {
    ContentView()
        .preferredColorScheme(.dark)
}
