//
//  LoadingView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack {
            Spacer() // Spacer added to center vertically
            CircleAnimationView(isLoading: $isLoading)
                .frame(width: 100, height: 100)
            Spacer() // Spacer added to center vertically
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
        .onAppear {
            // Code to execute when the view appears
        }
    }
}

struct CircleAnimationView: UIViewRepresentable {
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let circleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 100, height: 100))
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor(red: 22/255, green: 42/255, blue: 59/255, alpha: 1).cgColor
        circleLayer.lineWidth = 15
        circleLayer.fillColor = nil
        circleLayer.shadowOffset = CGSize(width: 0, height: 4)
        circleLayer.shadowRadius = 10
        circleLayer.shadowColor = UIColor(red: 22/255, green: 42/255, blue: 59/255, alpha: 1).cgColor
        circleLayer.shadowOpacity = 0.25
        view.layer.addSublayer(circleLayer)
        
        let label = UILabel(frame: CGRect(x: 0, y: 4, width: 100, height: 100))
        label.textAlignment = .center
        label.font = UIFont(name: "Parclo Serif ExtraBlack", size: 53)
        label.text = "5"
        label.textColor = UIColor(red: 22/255, green: 42/255, blue: 59/255, alpha: 1)
        label.layer.shadowOffset = CGSize(width: 0, height: 4)
        label.layer.shadowRadius = 10
        label.layer.shadowColor = UIColor(red: 22/255, green: 42/255, blue: 59/255, alpha: 1).cgColor
        label.layer.shadowOpacity = 0.25
        label.alpha = 0
        view.addSubview(label)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let label = uiView.subviews.compactMap({ $0 as? UILabel }).first else { return }

        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.fromValue = 0
        drawAnimation.toValue = 1
        drawAnimation.duration = 0.5
        drawAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let circleLayer = uiView.layer.sublayers?.first as? CAShapeLayer
        circleLayer?.add(drawAnimation, forKey: "drawCircleAnimation")

        DispatchQueue.main.asyncAfter(deadline: .now() + drawAnimation.duration - 0.1) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                label.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                    label.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                } completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
}
