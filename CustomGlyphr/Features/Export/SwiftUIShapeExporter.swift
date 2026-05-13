import Foundation

enum SwiftUIShapeExporter {
    
    @MainActor
    static func export(shapeName: String, commands: [PathCommand]) -> String {
        let sanitizedName = sanitizeTypeName(shapeName)
        let body = commands.map(commandCode).joined(separator: "\n")

        return """
        import SwiftUI

        struct \(sanitizedName): Shape {
            func path(in rect: CGRect) -> Path {
                var path = Path()
        \(body.indented(by: 8))
                return path
            }
        }
        """
    }

    private static func commandCode(_ command: PathCommand) -> String {
        switch command.kind {
        case .move:
            "path.move(to: \(pointCode(command.point)))"
        case .line:
            "path.addLine(to: \(pointCode(command.point)))"
        case .quad:
            "path.addQuadCurve(to: \(pointCode(command.point)), control: \(pointCode(command.control1 ?? command.point)))"
        case .cubic:
            "path.addCurve(to: \(pointCode(command.point)), control1: \(pointCode(command.control1 ?? command.point)), control2: \(pointCode(command.control2 ?? command.point)))"
        case .close:
            "path.closeSubpath()"
        }
    }

    private static func pointCode(_ point: NormalizedPoint) -> String {
        "CGPoint(x: rect.minX + rect.width * \(format(point.x)), y: rect.minY + rect.height * \(format(point.y)))"
    }

    private static func format(_ value: Double) -> String {
        let text = String(format: "%.4f", value)
        return text.replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }

    private static func sanitizeTypeName(_ value: String) -> String {
        let parts = value
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        let joined = parts.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        let fallback = joined.isEmpty ? "CustomShape" : joined

        if fallback.first?.isNumber == true {
            return "Shape\(fallback)"
        }
        return fallback
    }
}

private extension String {
    func indented(by spaces: Int) -> String {
        let padding = String(repeating: " ", count: spaces)
        return split(separator: "\n", omittingEmptySubsequences: false)
            .map { padding + $0 }
            .joined(separator: "\n")
    }
}
