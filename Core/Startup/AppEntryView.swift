import SwiftUI
import FirebaseAuth // Importante para verificar se já está logado

struct AppEntryView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true
    
    // Verifica se o usuário já está logado no Firebase ao abrir o app
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    
    var body: some View {
        ZStack {
            if showSplash {
                // 1. Splash Screen
                SplashView {
                    withAnimation { showSplash = false }
                }
            }
            else if !hasSeenOnboarding {
                // 2. Onboarding (se nunca viu)
                OnboardingView {
                    withAnimation { hasSeenOnboarding = true }
                }
            }
            else if isUserLoggedIn {
                // 3. Se já tiver usuário logado, vai direto pra Home
                // Substitua Text pela sua HomeView() real
                Text("🏠 Home View (Logado)")
            }
            else {
                // 4. Fluxo de Auth (Seleção -> Login/Registro)
                // AQUI ESTAVA O ERRO: Não passamos mais nada, ela se vira sozinha
                UserTypeSelectionView()
            }
        }
        .onAppear {
            // Ouve mudanças de estado do Auth (caso faça logout, volta pra tela inicial)
            Auth.auth().addStateDidChangeListener { _, user in
                isUserLoggedIn = (user != nil)
            }
        }
    }
}

#Preview {
    AppEntryView()
}
