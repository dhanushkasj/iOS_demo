//
//  AudioService.swift
//  iOS_Demo
//

import AVFoundation

@Observable
final class AudioService {
    private var player: AVAudioPlayer?

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }

    func play() {
        if player == nil {
            guard let url = Self.trackURL() else { return }
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.4
            player?.prepareToPlay()
        }
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
    }

    func stop() {
        guard let player else { return }
        player.stop()
        player.currentTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private static func trackURL() -> URL? {
        let name = "background_music"
        for ext in ["mp3", "m4a", "wav", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }
}
