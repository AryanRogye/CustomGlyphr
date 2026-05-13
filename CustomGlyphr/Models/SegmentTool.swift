//
//  SegmentTool.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//


enum SegmentTool: String, CaseIterable, Identifiable {
    case select = "Select"
    case line = "Line"
    case quad = "Quad"
    case cubic = "Cubic"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .select: "cursorarrow"
        case .line: "line.diagonal"
        case .quad: "point.3.connected.trianglepath.dotted"
        case .cubic: "scribble.variable"
        }
    }
}
