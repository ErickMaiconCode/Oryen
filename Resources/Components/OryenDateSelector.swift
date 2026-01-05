import SwiftUI

struct OryenDateSelector: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    @Binding var date: Date
    let range: ClosedRange<Date>
    
    @State private var showDatePicker = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Color("Cor Roxo"))
                .padding(.leading, 4)
            
            Button(action: { showDatePicker = true }) {
                HStack {
                    Text(dateFormatter.string(from: date))
                        .foregroundColor(Color("Cor Branca"))
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(Color("Cor Roxo"))
                }
                .padding()
                .background(Color("Cor Fundo").opacity(0.5).brightness(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showDatePicker ? Color("Cor Roxo") : Color.gray.opacity(0.3), lineWidth: showDatePicker ? 2 : 1)
                )
            }
        }
        // O Modal (Sheet) que sobe
        .sheet(isPresented: $showDatePicker) {
            VStack {
                HStack {
                    Text("Selecione a Data")
                        .font(.headline)
                        .foregroundColor(Color("Cor Branca"))
                    Spacer()
                    Button("Pronto") {
                        showDatePicker = false
                    }
                    .font(.headline)
                    .foregroundColor(Color("Cor Branca"))
                }
                .padding()
                
                Divider()
                
                DatePicker(
                    "",
                    selection: $date,
                    in: range,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                Text("Você precisa ter pelo menos 18 anos.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            // Fundo do Modal
            .background(Color("Cor Fundo").ignoresSafeArea())
            .presentationDetents([.height(350)])
            .presentationCornerRadius(24)
        }
    }
}

