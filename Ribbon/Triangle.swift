//
//  Triangle.swift
//  Ribbon
//
//  Created by Jessica Linden on 12/29/23.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
           var path = Path()

           let topPoint = CGPoint(x: rect.midX, y: rect.minY)
           let bottomLeftPoint = CGPoint(x: rect.minX, y: rect.maxY)
           let bottomRightPoint = CGPoint(x: rect.maxX, y: rect.maxY)

           path.move(to: topPoint)
           path.addLine(to: bottomLeftPoint)
           path.addLine(to: bottomRightPoint)
           path.closeSubpath()

           return path
       }
}
