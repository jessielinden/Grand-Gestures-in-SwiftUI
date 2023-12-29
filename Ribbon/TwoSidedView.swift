//
//  TwoSidedView.swift
//  Ribbon
//
//  Created by Jessica Linden on 1/1/24.
//

import SwiftUI

// Apple sample code
// https://github.com/bitrise-io/Fruta/blob/master/Shared/Components/FlipView.swift

struct TwoSidedView<Front: View, Back: View>: View {
    var visibleSide: TwoSidedSelection
    @ViewBuilder var front: Front
    @ViewBuilder var back: Back
    
    init(
        visibleSide: TwoSidedSelection,
        @ViewBuilder front: @escaping () -> Front,
        @ViewBuilder back: @escaping () -> Back) {
            self.visibleSide = visibleSide
            self.front = front()
            self.back = back()
        }
    
    var body: some View {
        ZStack {
            front
                .modifier(FlipModifier(side: .front, visibleSide: visibleSide))
            back
                .modifier(FlipModifier(side: .back, visibleSide: visibleSide))
        }
    }
}

enum TwoSidedSelection {
    case front
    case back
    
    mutating func toggle() {
        self = self == .front ? .back : .front
    }
}

struct FlipModifier: AnimatableModifier {
    var side: TwoSidedSelection
    var flipProgress: Double
    
    init(side: TwoSidedSelection, visibleSide: TwoSidedSelection) {
        self.side = side
        self.flipProgress = visibleSide == .front ? 0 : 1
    }
    
    public var animatableData: Double {
        get { flipProgress }
        set { flipProgress = newValue }
    }
    
    var visible: Bool {
        switch side {
        case .front:
            return flipProgress <= 0.5
        case .back:
            return flipProgress > 0.5
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(visible ? 1 : 0)
                .accessibility(hidden: !visible)
        }
        .scaleEffect(x: scale, y: 1.0)
        .rotation3DEffect(.degrees(flipProgress * -150),
                          axis: (x: 1.0, y: 0.0, z: 0.0),
                          anchor: .bottom,
                          perspective: 0.5)
    }
    
    var scale: CGFloat {
        switch side {
        case .front:
            return 1.0
        case .back:
            return -1.0
        }
    }
}

#Preview {
    struct TwoSidedPreview: View {
        @State private var visibleSide: TwoSidedSelection = .front
        var body: some View {
            TwoSidedView(visibleSide: visibleSide, front: {
                TwoSidedPreviewCell(visibleSide: $visibleSide)
            }, back: {
                TwoSidedPreviewCell(visibleSide: $visibleSide)
                    .rotationEffect(.degrees(180))
            })
            .animation(.default, value: visibleSide)
            .onTapGesture {
                visibleSide.toggle()
            }
        }
    }
    struct TwoSidedPreviewCell: View {
        @Binding var visibleSide: TwoSidedSelection
        var body: some View {
            Text("\(visibleSide == .front ? "front" : "back")").bold().foregroundColor(.white)       .font(.largeTitle)
                .padding()
                .background(visibleSide == .front ? .blue : .green)
        }
    }
    
    return TwoSidedPreview()
        .preferredColorScheme(.dark)
}
