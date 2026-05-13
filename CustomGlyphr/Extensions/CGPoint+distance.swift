//
//  CGPoint+distance.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

