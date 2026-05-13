import Foundation

enum PathCommandKind: String, CaseIterable, Identifiable {
    case move = "Move"
    case line = "Line"
    case quad = "Quad"
    case cubic = "Cubic"
    case close = "Close"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .move: "point.topleft.down.curvedto.point.bottomright.up"
        case .line: "line.diagonal"
        case .quad: "point.3.connected.trianglepath.dotted"
        case .cubic: "scribble.variable"
        case .close: "seal"
        }
    }
}

struct NormalizedPoint: Hashable {
    var x: Double
    var y: Double

    static let center = NormalizedPoint(x: 0.5, y: 0.5)

    func clamped() -> NormalizedPoint {
        NormalizedPoint(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
    }
    
    var formattedX: String {
        x.formatted(.number.precision(.fractionLength(3)))
    }
    
    var formattedY: String {
        y.formatted(.number.precision(.fractionLength(3)))
    }
}

struct PathCommand: Identifiable, Hashable {
    let id: UUID
    var kind: PathCommandKind
    var point: NormalizedPoint
    var control1: NormalizedPoint?
    var control2: NormalizedPoint?

    init(
        id: UUID = UUID(),
        kind: PathCommandKind,
        point: NormalizedPoint,
        control1: NormalizedPoint? = nil,
        control2: NormalizedPoint? = nil
    ) {
        self.id = id
        self.kind = kind
        self.point = point
        self.control1 = control1
        self.control2 = control2
    }

    var title: String {
        switch kind {
        case .move: "Move to"
        case .line: "Line to"
        case .quad: "Quad curve"
        case .cubic: "Cubic curve"
        case .close: "Close path"
        }
    }

    var summary: String {
        switch kind {
        case .close:
            "closeSubpath()"
        case .quad:
            "to \(point.shortDescription), c \(control1?.shortDescription ?? "--")"
        case .cubic:
            "to \(point.shortDescription), c1 \(control1?.shortDescription ?? "--"), c2 \(control2?.shortDescription ?? "--")"
        case .move, .line:
            point.shortDescription
        }
    }
}

extension NormalizedPoint {
    var shortDescription: String {
        "\(Self.format(x)), \(Self.format(y))"
    }

    private static func format(_ value: Double) -> String {
        let text = String(format: "%.3f", value)
        return text.replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }
}
