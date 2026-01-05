//
//  SplashView.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 16/12/25.
//

import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    @State private var animate = false
    var onFinished: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.6)
                    .animation(.easeOut(duration: 1.0), value: animate)

                Image("Logo - Oryen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 60)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 1.3).delay(0.5), value: animate)
            }
        }
        .onAppear {
            animate = true
            let totalDelay = 1.3 + 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView()
}
