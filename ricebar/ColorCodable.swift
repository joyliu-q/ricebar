import SwiftUI

struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        red = Double(components[0])
        green = Double(components[1])
        blue = Double(components[2])
        alpha = Double(components[3])
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let codableColor = try container.decode(CodableColor.self)
        self = codableColor.color
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let codableColor = CodableColor(color: self)
        try container.encode(codableColor)
    }
} 