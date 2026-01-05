import SwiftUI
import Lottie

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.colorScheme) private var colorScheme
    var onFinished: () -> Void = {}
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                skipButton
                
                pagesTabView
                
                progressIndicator
                
                continueButton
            }
        }
    }
    
    // MARK: - View Components
    private var backgroundColor: some View {
        LinearGradient(
            colors: [
                colorScheme == .dark ? Color("Cor Fundo") : Color.white,
                colorScheme == .dark ? Color("Cor Fundo").opacity(0.9) : Color.gray.opacity(0.03)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var skipButton: some View {
        HStack {
            Spacer()
            HStack{
                if viewModel.showSkipButton {
                    Button(action: viewModel.skipToEnd) {
                        Text("Pular")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color("Cor Roxo"))
                            .padding(.vertical, 10)
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color("Cor Roxo"))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showSkipButton)
    }
    
    private var pagesTabView: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.items.indices, id: \.self) { index in
                OnboardingPageView(item: viewModel.items[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.progressIndicators, id: \.index) { indicator in
                Capsule()
                    .fill(indicator.isActive ? Color("Cor Roxo") : Color.gray.opacity(0.3))
                    .frame(width: indicator.width, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: indicator.width)
            }
        }
        .padding(.vertical, 32)
    }
    
    private var continueButton: some View {
        Button(action: handleButtonTap) {
            HStack(spacing: 12) {
                Text(viewModel.buttonTitle)
                    .font(.headline)
                
                Image(systemName: viewModel.isLastPage ? "checkmark" : "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color("Cor Roxo"), Color("Cor Rosa")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color("Cor Roxo").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
        .animation(.spring(), value: viewModel.buttonTitle)
    }
    
    // MARK: - Actions
    private func handleButtonTap() {
        let shouldFinish = viewModel.handleButtonAction()
        
        if shouldFinish {
            hasSeenOnboarding = true
            onFinished()
        }
    }
}

#Preview {
    OnboardingView()
}
