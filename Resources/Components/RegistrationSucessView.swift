import SwiftUI
import Lottie

struct RegistrationSuccessView: View {
    @Environment(\.colorScheme) var colorScheme
    let userName: String
    let userType: UserType
    var onComplete: () -> Void
    
    @State private var timeRemaining = 2.5
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color("Cor Fundo") : Color.white)
            
            VStack {
                Spacer()
                
                LottieView(
                    name: "Success",
                    loopMode: .playOnce
                )
                .frame(width: 200, height: 200)
                
                Text("Tudo pronto, \(userName)!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Levando você para a tela inicial...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                
                Spacer()
                
                Button(action: onComplete) {
                    Text("Começar Agora")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeRemaining) {
                onComplete()
            }
        }
    }
}
