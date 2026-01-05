import SwiftUI

struct PasswordStrengthView: View {
    // Dados recebidos do ViewModel
    let strengthScore: Int // 0 a 6
    let strengthColor: Color
    let strengthLabel: String
    
    // Estados do Checklist
    let hasMinLength: Bool
    let hasNumber: Bool
    let hasUppercase: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 1. Barra de 6 Pontos
            HStack(spacing: 6) {
                ForEach(0..<6) { index in
                    RoundedRectangle(cornerRadius: 2)
                        // Lógica: Se o index é menor que o score, pinta.
                        .fill(index < strengthScore ? strengthColor : Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut.delay(Double(index) * 0.05), value: strengthScore)
                }
            }
            
            // 2. Label de Texto (Ex: "Força: Média")
            HStack {
                Text("Segurança da senha:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(strengthLabel)
                    .font(.caption.bold())
                    .foregroundColor(strengthColor)
                    // Anima a troca de texto
                    .contentTransition(.numericText())
                
                Spacer()
            }
            
            // 3. Checklist de Requisitos (O que falta para completar)
            VStack(alignment: .leading, spacing: 8) {
                RequirementRow(isValid: hasMinLength, text: "Mínimo de 6 caracteres")
                RequirementRow(isValid: hasNumber, text: "Pelo menos 1 número")
                RequirementRow(isValid: hasUppercase, text: "Pelo menos 1 letra maiúscula")
            }
            .padding(.top, 4)
        }
        .padding()
        // Estilo de "Card" interno
        .background(Color("Cor Fundo").opacity(0.5).brightness(0.05))
        .cornerRadius(12)
    }
}

// Subcomponente da linha do checklist
struct RequirementRow: View {
    let isValid: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Ícone animado
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray.opacity(0.5))
                .font(.caption)
                // Efeito de "bounce" quando completa
                .symbolEffect(.bounce, value: isValid)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? Color("Cor Branca") : .gray)
                .strikethrough(isValid)
        }
        .animation(.spring(), value: isValid)
    }
}
