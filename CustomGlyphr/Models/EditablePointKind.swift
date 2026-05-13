//
//  EditablePointKind.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

enum EditablePointKind: Hashable {
    case anchor
    case control1
    case control2
    
    var label: String {
        switch self {
        case .anchor: "Anchor"
        case .control1: "Control 1"
        case .control2: "Control 2"
        }
    }
}
