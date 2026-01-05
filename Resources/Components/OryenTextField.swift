import SwiftUI

struct OryenTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hierarquia 3: Label
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Color("Cor Roxo"))
                .padding(.leading, 4)
            
            // Hierarquia 4: Input Box
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled(keyboardType == .emailAddress)
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                }
                
                Image(systemName: icon)
                    .foregroundColor(isFocused ? Color("Cor Roxo") : .gray)
            }
            .padding()
            .background(Color("Cor Fundo").opacity(0.5).brightness(0.1)) // Surface Color
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color("Cor Roxo") : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
            )
        }
    }
}
