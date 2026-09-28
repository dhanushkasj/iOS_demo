//
//  GameCard.swift
//  iOS_Demo
//
//  Shared card button used on the home screen.
//

import SwiftUI

struct GameCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .opacity(0.9)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .opacity(0.7)
        }
        .foregroundStyle(.white)
        .padding()
        .background(color, in: RoundedRectangle(cornerRadius: 20))
    }
}
