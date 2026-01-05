import Foundation

struct MaskUtils{
    static func format(text: String, mask: String) -> String {
        let clean = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var result = ""
        var index = clean.startIndex
        
        for ch in mask where index < clean.endIndex {
            if ch == "#" {
                result.append(clean[index])
                index = clean.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    static func clean(_ text: String) -> String {
        return text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
