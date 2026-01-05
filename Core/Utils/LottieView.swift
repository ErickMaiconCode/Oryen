import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var speed: CGFloat = 1.0
    var playProgress: AnimationProgressTime? = nil
    var autoPlay: Bool = true
    var playDelay: TimeInterval = 0

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.animation = LottieAnimation.named(name)

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Armazena no context para reusar
        context.coordinator.animationView = animationView

        if autoPlay {
            playAnimation(animationView: animationView)
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Atualiza apenas propriedades que mudaram
        guard let animationView = context.coordinator.animationView else { return }
        
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = contentMode
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func playAnimation(animationView: LottieAnimationView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + playDelay) {
            if let progress = playProgress {
                animationView.play(fromProgress: 0, toProgress: progress, loopMode: loopMode)
            } else {
                animationView.play()
            }
        }
    }

    class Coordinator {
        var animationView: LottieAnimationView?
    }
}
