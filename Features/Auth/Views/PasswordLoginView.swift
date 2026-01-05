import SwiftUI

struct PasswordLoginView: View {
    @StateObject private var viewModel: PasswordLoginViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    init(userType: UserType, documentNumber: String) {
        _viewModel = StateObject(wrappedValue: PasswordLoginViewModel(userType: userType, documentNumber: documentNumber))
    }
    
    var body: some View {
        ZStack {
            Color("Cor Fundo").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header com Voltar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("Cor Branca"))
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Bem-vindo de volta!")
                            .font(.title.bold())
                            .foregroundColor(Color("Cor Branca"))
                        
                        Text("Digite sua senha para acessar.")
                            .foregroundColor(.gray)
                    }
                    
                    // Input de Senha (Reusando estilo Oryen)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SENHA")
                            .font(.caption.bold())
                            .foregroundColor(Color("Cor Roxo"))
                            .padding(.leading, 4)
                        
                        HStack {
                            if viewModel.isPasswordVisible {
                                TextField("Sua senha", text: $viewModel.password)
                                    .focused($isFocused)
                            } else {
                                SecureField("Sua senha", text: $viewModel.password)
                                    .focused($isFocused)
                            }
                            
                            Button(action: { viewModel.togglePasswordVisibility() }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(Color("Cor Roxo"))
                            }
                        }
                        .padding()
                        .background(Color("Cor Fundo").opacity(0.5).brightness(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFocused ? Color("Cor Roxo") : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                        )
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                    
                    Button("Esqueci minha senha") {
                        // Ação de recuperação
                    }
                    .font(.caption)
                    .foregroundColor(Color("Cor Roxo"))
                }
                .padding(24)
                
                Spacer()
                
                Button(action: {
                    Task { await viewModel.login() }
                }) {
                    ZStack {
                        if viewModel.isLoading { ProgressView().tint(.white) }
                        else { Text("Entrar").font(.headline) }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(viewModel.canProceed ? Color("Cor Roxo") : Color.gray.opacity(0.3))
                    .cornerRadius(16)
                }
                .disabled(!viewModel.canProceed || viewModel.isLoading)
                .padding(24)
            }
        }
        .onAppear { isFocused = true }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.isAuthenticated) {
            // HOME VIEW DO APP
            Text("🏠 Home View - Logado com Sucesso")
        }
    }
}
