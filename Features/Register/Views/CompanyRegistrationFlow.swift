import SwiftUI

struct CompanyRegistrationFlow: View {
    let initialCNPJ: String
    
    @StateObject private var viewModel: CompanyRegistrationViewModel
    @Environment(\.dismiss) var dismiss
    
    init(initialCNPJ: String){
        self.initialCNPJ = initialCNPJ
        _viewModel = StateObject(wrappedValue: CompanyRegistrationViewModel(initialCNPJ: initialCNPJ))
    }
    
    var body: some View {
        ZStack{
            Color("Cor Fundo").ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack{
                    Button(action: {
                        if viewModel.currentStep == .cnpj || viewModel.currentStep == .basicInfo {
                            dismiss()
                        } else {
                            viewModel.previousStep()
                        }
                    }
                    ){
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("Cor Branca"))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(spacing: 24) {
                    VStack(spacing: 8){
                        Text(viewModel.currentStep.title)
                            .font(.title.bold())
                            .foregroundStyle(Color("Cor Branca"))
                        
                        Text(viewModel.currentStep.subtitle)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .transition(.opacity)
                    
                    ScrollView{
                        VStack(spacing: 20){
                            switch viewModel.currentStep {
                            case .cnpj:
                                OryenTextField(label: "CNPJ", placeholder: "00.000.000/0000-00", icon: "building.2", text: $viewModel.cnpj, keyboardType: .numberPad)
                                    .onChange(of: viewModel.cnpj) { viewModel.applyCNPJMask($0)
                                    }
                            case .basicInfo:
                                OryenTextField(label: "RAZÃO SOCIAL", placeholder: "Nome Oficial Ltda", icon: "doc.text", text: $viewModel.legalName)
                                OryenTextField(label: "NOME FANTASIA", placeholder: "Nome da Marca", icon: "star", text: $viewModel.tradeName)
                            case .details:
                                VStack(alignment: .leading){
                                    Text("TAMANHO DA EMPRESA").font(.caption.bold()).foregroundStyle(Color("Cor Roxo"))
                                    Picker("Tamanho", selection: $viewModel.selectedSize){
                                        ForEach(CompanySize.allCases, id: \.self) { size in
                                            Text(size.rawValue).tag(size)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding()
                                    .background(Color("Cor Fundo").opacity(0.5).brightness(0.1))
                                    .cornerRadius(12)
                                }
                                OryenTextField(label: "SEGMENTO", placeholder: "Ex: Varejo, Tecnologia...", icon: "tag", text: $viewModel.segment)
                                OryenTextField(label: "SEU CARGO", placeholder: "Ex: Sócio, Gerente...", icon: "person.badge.key", text: $viewModel.responsibleRole)
                            case .contact:
                                OryenTextField(label: "EMAIL CORPORATIVO", placeholder: "contato@gmail.com", icon: "envelope", text: $viewModel.corporateEmail, keyboardType: .emailAddress)
                                OryenTextField(label: "TELEFONE/WHATSSAP", placeholder: "(00) 00000-0000", icon: "phone", text: $viewModel.corporatePhone, keyboardType: .phonePad)
                                    .onChange(of: viewModel.corporatePhone) { viewModel.applyPhoneMask($0)}
                            case .password:
                                OryenTextField(label: "CRIE UMA SENHA", placeholder: "Mínimo 6 caracteres", icon: "lock", text: $viewModel.password, isSecure: true)
                                OryenTextField(label: "CONFIRME A SENHA", placeholder: "Repita a senha", icon: "lock", text: $viewModel.confirmPassword, isSecure: true)
                            }
                        }
                        .padding()
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .multilineTextAlignment(.center )
                    }
                    Spacer()
                    
                    Button(action: {
                        withAnimation { viewModel.nextStep()}
                    }) {
                        ZStack{
                            Group {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Continuar").font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(viewModel.isStepValid ? Color("Cor Roxo") : Color.gray.opacity(0.3))
                            .cornerRadius(16)
                        }
                    }
                    .disabled(!viewModel.isStepValid || viewModel.isLoading)
                    .padding(24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.isRegistered){
                Text("Empresa cadastrada com sucesso! Bem Vindo ao Dashboard")
            }
        }
    }
    
    
}
