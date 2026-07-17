//
//  AppBackground.swift
//  iOS_Demo
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        Image("AppBackground")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
    }
}

private struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Mini Games")
            .font(.largeTitle.bold())
        Text("Pick a game to play")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .appBackground()
}
