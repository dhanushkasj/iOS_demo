//
//  LaunchVideoView.swift
//  iOS_Demo
//

import AVFoundation
import SwiftUI

struct LaunchVideoView: View {
    static let playbackDuration: Double = 4

    let onFinish: () -> Void

    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let player {
                PlayerLayerView(player: player)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onFinish)
        .statusBarHidden()
        .task { await start() }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func start() async {
        guard let url = Bundle.main.url(forResource: "launch", withExtension: "mp4") else {
            onFinish()
            return
        }

        let player = AVPlayer(url: url)
        player.isMuted = true
        self.player = player
        player.play()

        try? await Task.sleep(for: .seconds(Self.playbackDuration))
        onFinish()
    }
}

private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

#Preview {
    LaunchVideoView { }
}
