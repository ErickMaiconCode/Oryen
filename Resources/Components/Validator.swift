import Foundation

class Validator {
    static func isValidCNPJ(_ cnpj: String) -> Bool {
        let numbers = cnpj.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard numbers.count == 14 else { return false }
        
        let set = Set(numbers)
        if set.count == 1 { return false }
        
        func digitCalc(_ slice: [Int]) -> Int {
            var number = 1
            let digit = slice.reversed().reduce(0) { total, current in
                number = 1
                return total + (current * (number > 9 ? number - 8 : number))
            }
            let result = 11 - (digit % 11)
            return result > 9 ? 0 : result
        }
        
        let digits = numbers.compactMap { Int(String($0)) }
        let firstDigit = digitCalc(Array(digits.prefix(12)))
        let secondDigit = digitCalc(Array(digits.prefix(13)))
        
        return firstDigit == digits[12] && secondDigit == digits[13]
    }
}

extension MaskUtils {
    static func formatCNPJ(_ cnpj: String) -> String {
        return format(text: cnpj, mask: "##.###.###/####-##")
    }
}
