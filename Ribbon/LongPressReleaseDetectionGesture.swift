//
//  LongPressReleaseDetectionGesture.swift
//  Ribbon
//
//  Created by Jessica Linden on 3/18/24.
//

import SwiftUI

public struct LongPressReleaseDetectionGesture: Gesture {
    enum PressingState {
        case pressed, success, failure
    }
    
    let maxX: CGFloat
    let maxY: CGFloat
    let minimumDuration: CGFloat = 0.5
    let pressingState: (PressingState) -> Void
    
    public var body: some Gesture {
        SequenceGesture(
            LongPressGesture(minimumDuration: minimumDuration)
                .onEnded { _ in
                    pressingState(.pressed)
                },
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    pressingState((0...maxX).contains(value.location.x) &&
                                  (0...maxY).contains(value.location.y) ?
                        .success : .failure)
                }
        )
    }
}
