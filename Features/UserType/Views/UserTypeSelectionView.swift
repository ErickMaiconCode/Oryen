import SwiftUI
import Lottie

struct UserTypeSelectionView: View {
    @StateObject private var viewModel = UserTypeSelectionViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Controle de Navegação para a próxima tela
    @State private var navigateToInput = false
    
    var body: some View {
        ZStack {
            Color("Cor Fundo").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header Rico
                VStack(spacing: 16) {
                    Image("Logo") // Certifique-se que o asset existe no Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .shadow(color: Color("Cor Roxo").opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 4) {
                        Text("Bem-vindo ao")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("Cor Branca"))
                        
                        // TEXTO ORYEN COM GRADIENTE
                        Text("Oryen")
                            .font(.system(size: 42, weight: .heavy))
                            .overlay(
                                LinearGradient(
                                    colors: [Color("Cor Roxo"), Color("Cor Rosa"), Color("Cor Laranja")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text("Oryen")
                                        .font(.system(size: 42, weight: .heavy))
                                )
                            )
                            // Oculta o texto base para mostrar só o gradiente
                            .foregroundColor(.clear)
                            
                        Text("Escolha como deseja acessar")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // MARK: - Animação Contextual
                LottieView(
                    name: viewModel.currentLottieFileName,
                    loopMode: .loop
                )
                .frame(height: 220)
                .id(viewModel.selectedUserType)
                
                // Descrição Dinâmica
                Text(viewModel.currentDescription)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                    .padding(.bottom, 30)
                
                Spacer()
                
                // MARK: - Seletor
                ToggleSelector(selected: $viewModel.selectedUserType)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                
                // Botão Continuar
                Button(action: {
                    navigateToInput = true
                }) {
                    HStack {
                        Text("Continuar")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [Color("Cor Roxo"), Color("Cor Rosa")], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color("Cor Roxo").opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $navigateToInput) {
            DocumentInputView(userType: viewModel.selectedUserType)
        }
    }
}
