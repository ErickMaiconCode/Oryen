import SwiftUI
import Lottie

struct OnboardingPageView: View {
    let item: OnboardingItem
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 24) {
                Spacer()
                
                // Animação Lottie
                LottieView(
                    name: item.animationName,
                    loopMode: .loop,
                    contentMode: .scaleAspectFit
                )
                .frame(height: min(geo.size.height * 0.4, 400))
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Título com gradiente no "Oryen"
                titleView
                    .padding(.horizontal, 32)
                
                // Descrição
                Text(item.description)
                    .font(.body)
                    .foregroundColor(Color("Cor Branca"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if item.title.contains("Oryen") {
            let parts = item.title.components(separatedBy: "Oryen")
            
            if parts.count == 2 {
                VStack(spacing: 4) {
                    Text(parts[0].trimmingCharacters(in: .whitespaces))
                        .font(.title.bold())
                        .foregroundColor(Color("Cor Branca"))
                    
                    Text("Oryen")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("Cor Roxo"),
                                    Color("Cor Rosa"),
                                    Color("Cor Azul")
                                ]),
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                }
                .multilineTextAlignment(.center)
            } else {
                Text(item.title)
                    .font(.title.bold())
                    .foregroundColor(Color("Cor Branca"))
                    .multilineTextAlignment(.center)
            }
        } else {
            Text(item.title)
                .font(.title.bold())
                .foregroundColor(Color("Cor Branca"))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingPageView(
        item: OnboardingItem(
            title: "Boas Vindas ao Oryen",
            description: "Transforme reclamações em soluções. Gerencie o feedback dos seus clientes de forma simples e eficiente.",
            animationName: "Gradient Infinite Sign"
        )
    )
}
