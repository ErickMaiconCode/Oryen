import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    
    let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Boas Vindas ao Oryen",
            description: "Transforme reclamações em soluções. Gerencie o feedback dos seus clientes de forma simples e eficiente.",
            animationName: "Gradient Infinite Sign"
        ),
        OnboardingItem(
            title: "Sua Voz Importa",
            description: "Com o Oryen, suas sugestões e reclamações chegam diretamente a quem resolve. Transforme sua experiência com feedbacks que geram mudança real.",
            animationName: "Chat"
        ),
        OnboardingItem(
            title: "Dados que inspiram decisões",
            description: "Acompanhe resultados, descubra tendências e transforme feedbacks em oportunidades reais através de insights visuais.",
            animationName: "Line Graph"
        ),
    ]
    
    // MARK: - Computed Properties
    var isLastPage: Bool {
        currentIndex == items.count - 1
    }
    
    var currentItem: OnboardingItem {
        items[currentIndex]
    }
    
    var buttonTitle: String {
        isLastPage ? "Começar" : "Próximo"
    }
    
    var showSkipButton: Bool {
        !isLastPage
    }
    
    var progressIndicators: [(index: Int, isActive: Bool, width: CGFloat)] {
        items.indices.map { index in
            (
                index: index,
                isActive: index == currentIndex,
                width: index == currentIndex ? 40 : 10
            )
        }
    }
    
    // MARK: - Actions
    func nextPage() {
        guard currentIndex < items.count - 1 else { return }
        withAnimation(.easeInOut) {
            currentIndex += 1
        }
    }
    
    func skipToEnd() {
        withAnimation(.easeInOut) {
            currentIndex = items.count - 1
        }
    }
    
    func handleButtonAction() -> Bool {
        if isLastPage {
            return true // Sinaliza que deve finalizar
        } else {
            nextPage()
            return false
        }
    }
}
