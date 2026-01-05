import SwiftUI
import Lottie

struct UserTypeSelectionView: View {
    @StateObject private var viewModel = UserTypeSelectionViewModel()
    @Environment(\.colorScheme) var colorScheme
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {

            (colorScheme == .dark ? Color("Cor Fundo") : Color(.white))
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                

                VStack(spacing: 8) {
                    Text("Bem Vindo à")
                        .font(.title.bold())
                        .foregroundStyle(Color("Cor Descrição"))
                    
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
                .padding(.bottom, 40)

                VStack(spacing: 24) {
                    LottieView(
                        name: viewModel.selectedUserType.lottieFileName,
                        loopMode: .loop,
                        contentMode: .scaleAspectFit,
                        speed: 1.0
                    )
                    .frame(height: 300)
                    .id(viewModel.selectedUserType)
                    
                    Text(viewModel.selectedUserType.description)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("Cor Descrição").opacity(0.7))
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 20)
                .frame(maxHeight: .infinity)
                .transition(.opacity)

                ToggleSelector(selected: $viewModel.selectedUserType)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 24)
                
                // Botão continuar
                Button(action: {
                    viewModel.saveAndContinue()
                    onComplete()
                }) {
                    HStack {
                        Text("Continuar")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(colorScheme == .dark ? Color("Cor Roxo") : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(colorScheme == .dark ? Color.white : Color("Cor Roxo"))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    UserTypeSelectionView {
        print("Completou seleção")
    }
}
