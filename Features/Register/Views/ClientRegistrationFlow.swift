import SwiftUI

struct ClientRegistrationFlow: View {
    @StateObject private var viewModel: ClientRegistrationViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    init(cpf: String) {
        _viewModel = StateObject(wrappedValue: ClientRegistrationViewModel(cpf: cpf))
    }
    
    var body: some View {
        ZStack {
            // Background Dark
            Color("Cor Fundo").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 1. Header (Atualizado com Lógica de Cancelar/Voltar)
                headerView
                
                // 2. Progress Bar
                progressBar
                    .padding(.bottom, 100) // Ajuste de espaçamento
                
                // 3. Área de Scroll (Conteúdo)
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Títulos com Animação
                        VStack(alignment: .leading, spacing: 15) {
                            Text(viewModel.currentStep.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("Cor Branca"))
                                .id("title-\(viewModel.currentStep.rawValue)")
                                .transition(.push(from: .trailing))
                            
                            Text(viewModel.currentStep.subtitle)
                                .font(.body)
                                .foregroundColor(.gray)
                                .id("sub-\(viewModel.currentStep.rawValue)")
                                .transition(.opacity)
                        }
                        
                        // Inputs (Com Máscaras e Medidor de Senha)
                        inputSection
                        
                        // Mensagem de Erro
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // 4. Botão de Ação
                actionButton
                    .padding(24)
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentStep)
        .navigationDestination(isPresented: $viewModel.isRegistered) {
            RegistrationSuccessView(userName: viewModel.name, userType: .client) { }
        }
        .onAppear { isFocused = true }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {
                if viewModel.currentStep == .name {
                    dismiss() // Cancela todo o fluxo
                } else {
                    viewModel.previousStep() // Volta um passo
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    // Texto muda dependendo do passo
                    Text(viewModel.currentStep == .name ? "Cancelar" : "Voltar")
                }
                .font(.headline)
                .foregroundColor(Color("Cor Roxo").opacity(0.8))
                .padding(10)
            }
            Spacer()
            
            Text("PASSO \(viewModel.currentStep.rawValue + 1)/\(RegistrationStep.allCases.count)")
                .font(.caption.bold())
                .foregroundColor(Color("Cor Roxo"))
                .tracking(1)
        }
        .padding(.horizontal, 16) // Ajuste para alinhar com a margem
        .padding(.top, 10)
    }
    
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(RegistrationStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color("Cor Roxo") : Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private var inputSection: some View {
        Group {
            switch viewModel.currentStep {
            case .name:
                OryenTextField(label: "NOME COMPLETO", placeholder: "Ex: João Silva", icon: "person", text: $viewModel.name)
                    .focused($isFocused)
                
            case .email:
                OryenTextField(label: "E-MAIL", placeholder: "seu@email.com", icon: "envelope", text: $viewModel.email, keyboardType: .emailAddress)
                        .focused($isFocused)
                        .onChange(of: viewModel.email) { newValue in
                            viewModel.email = newValue.lowercased()
                            if viewModel.errorMessage != nil {
                                viewModel.errorMessage = nil
                            }
                        }
                
            case .phone:
                OryenTextField(label: "TELEFONE", placeholder: "(00) 00000-0000", icon: "phone", text: $viewModel.phone, keyboardType: .numberPad)
                    .focused($isFocused)
                    .onChange(of: viewModel.phone) { newValue in
                        viewModel.applyPhoneMask(newValue)
                    }
                
            case .birthDate:
                OryenDateSelector(
                    label: "SELECIONE SUA DATA",
                    date: $viewModel.birthDate,
                    range: viewModel.dateRange
                )
                
            case .password:
                VStack(spacing: 20) {
                    OryenTextField(label: "SENHA", placeholder: "Crie sua senha", icon: "lock", text: $viewModel.password, isSecure: true)
                        .focused($isFocused)
                    
                    // Integração do Componente de Força
                    PasswordStrengthView(
                        strengthScore: viewModel.passwordStrengthScore, // 0 a 6
                        strengthColor: viewModel.passwordStrengthColor, // Cor dinâmica
                        strengthLabel: viewModel.passwordStrengthLabel, // Fraca/Média/Forte
                        hasMinLength: viewModel.hasMinLength,
                        hasNumber: viewModel.hasNumber,
                        hasUppercase: viewModel.hasUppercase
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
            case .confirmPassword:
                OryenTextField(label: "CONFIRMAR SENHA", placeholder: "Repita a senha", icon: "lock.shield", text: $viewModel.confirmPassword, isSecure: true)
                    .focused($isFocused)
            }
        }
    }
    
    private var actionButton: some View {
        Button(action: viewModel.nextStep) {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(viewModel.currentStep == .confirmPassword ? "Criar Conta" : "Continuar")
                        .font(.headline.bold())
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(viewModel.isStepValid ? Color("Cor Roxo") : Color.gray.opacity(0.3))
            .cornerRadius(16)
            .shadow(color: viewModel.isStepValid ? Color("Cor Roxo").opacity(0.4) : .clear, radius: 15, x: 0, y: 10)
        }
        .disabled(!viewModel.isStepValid || viewModel.isLoading)
    }
}

#Preview {
    ClientRegistrationFlow(cpf: "47422421819")
}
