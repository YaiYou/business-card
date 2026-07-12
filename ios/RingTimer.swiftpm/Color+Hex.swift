import SwiftUI

extension Color {
    /// Build a Color from a 0xRRGGBB integer, e.g. Color(hex: 0x7AA4DD).
    init(hex: UInt) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
