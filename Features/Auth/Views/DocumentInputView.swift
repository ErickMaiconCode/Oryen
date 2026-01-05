import SwiftUI

struct DocumentInputView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    init(userType: UserType) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(userType: userType))
    }
    
    var body: some View {
        // CORREÇÃO CRÍTICA: NavigationStack é obrigatório para navigationDestination funcionar
        NavigationStack {
            ZStack {
                Color("Cor Fundo").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Navigation
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(Color("Cor Branca"))
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    VStack(spacing: 32) {
                        // MARK: - Títulos Hierárquicos
                        VStack(spacing: 12) {
                            Text(viewModel.titleText)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color("Cor Branca"))
                            
                            Text("Usaremos este dado para localizar seu cadastro ou iniciar um novo.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        // MARK: - Input com Máscara
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.documentLabel)
                                .font(.caption.bold())
                                .foregroundColor(Color("Cor Roxo"))
                                .padding(.leading, 4)
                            
                            HStack {
                                TextField(viewModel.documentPlaceholder, text: $viewModel.documentNumber)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 20, weight: .medium))
                                    .focused($isFocused)
                                    .onChange(of: viewModel.documentNumber) { newValue in
                                        viewModel.applyMask(newValue)
                                    }
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Image(systemName: viewModel.documentIcon)
                                        .foregroundColor(Color("Cor Roxo"))
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(Color("Cor Fundo").opacity(0.5).brightness(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isFocused ? Color("Cor Roxo") : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                            )
                        }
                        
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Botão
                    Button(action: { Task { await viewModel.validateDocument() } }) {
                        Text("Continuar")
                            .font(.headline)
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
            // Os Destinations precisam estar DENTRO da NavigationStack
            .navigationDestination(isPresented: $viewModel.shouldNavigateToPassword) {
                PasswordLoginView(
                    userType: viewModel.userType,
                    documentNumber: MaskUtils.clean(viewModel.documentNumber)
                )
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToRegister) {
                if viewModel.userType == .client {
                    ClientRegistrationFlow(cpf: MaskUtils.clean(viewModel.documentNumber))
                } else {
                    CompanyRegistrationFlow(initialCNPJ: MaskUtils.clean(viewModel.documentNumber))
                }
            }
        } // Fim da NavigationStack
    }
}
