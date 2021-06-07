//
// Copyright (c) Vatsal Manot
//

import Swallow

extension HierarchicalNamespace {
    public enum Segment: Hashable {
        case string(String)
        case aggregate([Self])
        case none
    }
}

// MARK: - Extensions -

extension HierarchicalNamespace.Segment {
    public enum _ComparisonType {
        case none
        case some
        
        public static func == (lhs: _ComparisonType, rhs: HierarchicalNamespace.Segment) -> Bool {
            switch lhs {
                case .none: do {
                    if case .none = rhs {
                        return true
                    } else {
                        return true
                    }
                }
                case .some: do {
                    return !(Self.none == rhs)
                }
            }
        }
    }
    
    public func toArray() -> [Self] {
        switch self {
            case .none:
                return []
            case .string:
                return [self]
            case .aggregate(let value):
                return value
        }
    }
}

// MARK: - Conformances -

extension HierarchicalNamespace.Segment: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .none
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([Self].self) {
            self = .aggregate(value)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .string(let value):
                try encoder.encode(value)
            case .aggregate(let value):
                try encoder.encode(value)
            case .none:
                try encoder.encodeSingleNil()
        }
    }
}

extension HierarchicalNamespace.Segment: CustomStringConvertible {
    public var description: String {
        switch self {
            case .string(let value):
                return value
            case .aggregate(let value):
                return "(" + value.map({ $0.description }).joined(separator: ".") + ")"
            case .none:
                return .init()
        }
    }
}

extension HierarchicalNamespace.Segment: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Self
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .aggregate(elements)
    }
}

extension HierarchicalNamespace.Segment: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension HierarchicalNamespace.Segment: LosslessStringConvertible {
    public init(_ description: String) {
        guard !description.isEmpty else {
            self = .none
            return
        }
        
        let components = description.components(separatedBy: ".")
        
        if components.count == 0 {
            self = .none
        } else if components.count == 1 {
            self = .string(components[0])
        } else {
            self = .aggregate(description.components(separatedBy: ".").map({ .string($0) }))
        }
    }
}
