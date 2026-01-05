import SwiftUI

struct ToggleSelector: View {
    @Binding var selected: UserType
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ToggleItem(
                title: UserType.client.title,
                type: .client,
                selected: $selected,
                animation: animation
            )
            
            ToggleItem(
                title: UserType.company.title,
                type: .company,
                selected: $selected,
                animation: animation
            )
        }
        .padding(4)
        .background(colorScheme == .dark ? Color.gray.opacity(0.07) : Color.black.opacity(0.07))
        .cornerRadius(20)
    }
}

struct ToggleItem: View {
    let title: String
    let type: UserType
    @Binding var selected: UserType
    var animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7)) {
                selected = type
            }
        } label: {
            ZStack {
                if selected == type {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("Cor Roxo"),
                            Color("Cor Rosa"),
                            Color("Cor Laranja")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .matchedGeometryEffect(id: "toggleBackground", in: animation)
                    .cornerRadius(16)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(selected == type ? .white : Color("Cor Descrição").opacity(0.7))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .frame(height: 48)
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
    }
}
