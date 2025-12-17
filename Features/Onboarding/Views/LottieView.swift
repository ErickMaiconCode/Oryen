//
//  LottieView.swift
//  Oryen
//
//  Created by You on 16/12/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var speed: CGFloat = 1.0

    private let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed

        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Carrega a animação pelo nome do arquivo no bundle principal
        animationView.animation = LottieAnimation.named(name)
        animationView.play()

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Atualiza propriedades se mudarem dinamicamente
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed

        // Se o nome da animação mudar em tempo de execução, recarrega e toca
        if animationView.animation?.name != name {
            animationView.animation = LottieAnimation.named(name)
            animationView.play()
        }
    }
}
