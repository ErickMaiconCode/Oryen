//
//  WelcomeView.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 16/12/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 36) {
                // Animação Lottie usando seu wrapper
                LottieView(name: "Welcome")
                    .frame(height: 240)
                    .padding(.top, 60)

                VStack(spacing: 10) {
                    Text("Bem‑vindo ao Oryen")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("Gerencie feedbacks e transforme vozes em insights.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                Button {
                    print("Avançar para CPF/Login")
                    // Aqui você encaminha para a próxima view
                } label: {
                    Text("Começar")
                        .font(.headline)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(30)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
        .animation(.easeInOut, value: UUID())
    }
}

#Preview {
    WelcomeView()
}
