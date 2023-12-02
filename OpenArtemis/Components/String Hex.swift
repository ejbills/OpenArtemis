import SwiftUI

extension String {
    // Simple hash function to generate a unique integer from the input string
    func hashCode() -> Int {
        var hash: UInt64 = 5381
        let utf8 = self.utf8
        for byte in utf8 {
            hash = 127 &* (hash & 0x00ffffffffffffff) &+ UInt64(byte)
        }
        return Int(hash)
    }
    
    // Generate a hex code based on the input string
    func generateHexCode() -> String {
        let hashValue = abs(self.hashCode())
        let red = UInt8((hashValue & 0xFF0000) >> 16)
        let green = UInt8((hashValue & 0x00FF00) >> 8)
        let blue = UInt8(hashValue & 0x0000FF)
        let hexCode = String(format: "#%02X%02X%02X", red, green, blue)
        return hexCode
    }
}

func getColorFromInputString(_ inputString: String) -> Color {
    let hexCode = inputString.generateHexCode()
    let hexSubstring = hexCode.dropFirst() // Skip the "#" character
    var rgbValue: UInt64 = 0
    Scanner(string: String(hexSubstring)).scanHexInt64(&rgbValue)
    
    let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
    let blue = Double(rgbValue & 0x0000FF) / 255.0
    
    return Color(red: red, green: green, blue: blue)
}
