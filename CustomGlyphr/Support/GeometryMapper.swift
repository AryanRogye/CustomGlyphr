import SwiftUI

enum GeometryMapper {
    static func drawingRect(in size: CGSize) -> CGRect {
        let inset: CGFloat = 28
        let side = max(min(size.width, size.height) - inset * 2, 120)
        return CGRect(
            x: (size.width - side) / 2,
            y: (size.height - side) / 2,
            width: side,
            height: side
        )
    }

    static func canvasPoint(from point: NormalizedPoint, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * point.x,
            y: rect.minY + rect.height * point.y
        )
    }

    static func normalizedPoint(from point: CGPoint, in rect: CGRect) -> NormalizedPoint {
        guard rect.width > 0, rect.height > 0 else { return .center }
        return NormalizedPoint(
            x: (point.x - rect.minX) / rect.width,
            y: (point.y - rect.minY) / rect.height
        ).clamped()
    }
}
