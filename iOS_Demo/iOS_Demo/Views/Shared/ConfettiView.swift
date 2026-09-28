//
//  ConfettiView.swift
//  iOS_Demo
//

import SwiftUI

struct ConfettiView: View {
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    var count = 90

    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiShape(index: piece.id)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .rotationEffect(.degrees(animate ? piece.spin : 0))
                        .position(
                            x: piece.x * geo.size.width,
                            y: animate ? geo.size.height + 60 : -60
                        )
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
            .onAppear {
                pieces = (0..<count).map { index in
                    ConfettiPiece(
                        id: index,
                        x: Double(index % 20) / 20.0 + Double.random(in: -0.03...0.03),
                        size: CGFloat.random(in: 7...13),
                        color: colors[index % colors.count],
                        spin: Double.random(in: 180...900),
                        duration: Double.random(in: 1.8...3.2),
                        delay: Double.random(in: 0...0.6)
                    )
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(60))
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id: Int
    let x: Double
    let size: CGFloat
    let color: Color
    let spin: Double
    let duration: Double
    let delay: Double
}

private struct ConfettiShape: Shape {
    let index: Int

    func path(in rect: CGRect) -> Path {
        if index % 3 == 0 {
            return Path(ellipseIn: rect)
        } else {
            return Path(roundedRect: rect, cornerRadius: rect.width * 0.2)
        }
    }
}

#Preview {
    ConfettiView()
        .background(Color(.systemBackground))
}
