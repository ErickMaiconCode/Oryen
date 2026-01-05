import SwiftUI

struct OryenDatePicker: View {
    let label: String
    @Binding var date: Date
    let limit: Date // Data máxima permitida
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hierarquia 3: Label
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Color("Cor Roxo"))
                .padding(.leading, 4)
            
            // Hierarquia 4: Input Box
            HStack {
                // Configuração Crítica do DatePicker
                DatePicker(
                    "",
                    selection: $date,
                    in: ...limit, // TRAVA VISUAL: Bloqueia datas futuras ao limite
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .colorScheme(.dark) // Mantém texto branco/legível
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(Color("Cor Roxo"))
            }
            .padding()
            .background(Color("Cor Fundo").opacity(0.5).brightness(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Cor Roxo"), lineWidth: 2) // Sempre destaque
            )
        }
        
    }
}
