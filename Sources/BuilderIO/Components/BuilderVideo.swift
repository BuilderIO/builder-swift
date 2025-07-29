import AVKit
import SwiftUI

struct BuilderVideo: BuilderViewProtocol {
  static let componentType: BuilderComponentType = .video

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  // Video properties
  var videoURL: URL?
  var autoPlay: Bool = false
  var controls: Bool = true
  var muted: Bool = true
  var loop: Bool = true
  var playsInline: Bool = true
  var contentMode: ContentMode = .fit
  var aspectRatio: CGFloat? = nil

  // Poster image properties
  var posterImageURL: URL?

  // AVPlayer
  @State private var player: AVPlayer?
  @State private var playerLayer: AVPlayerLayer?
  // New state to manage play button visibility and video playing state
  @State private var showOverlay: Bool
  @State private var isPlaying: Bool = false

  init(block: BuilderBlockModel) {
    self.block = block
    self.children = block.children

    let options = block.component?.options?.dictionaryValue

    // Video URL
    if let videoString = options?["video"]?.stringValue {
      self.videoURL = URL(string: videoString)
    }
    if let videoBinding = block.codeBindings(for: "video")?.stringValue {
      self.videoURL = URL(string: videoBinding)
    }

    // Video options
    self.autoPlay = options?["autoPlay"]?.boolValue ?? false
    self.controls = options?["controls"]?.boolValue ?? true
    self.muted = options?["muted"]?.boolValue ?? true
    self.loop = options?["loop"]?.boolValue ?? true
    self.playsInline = options?["playsInline"]?.boolValue ?? true

    // Content mode and aspect ratio for video
    if let fit = options?["fit"]?.stringValue {
      switch fit {
      case "cover":
        self.contentMode = .fill
      case "contain":
        self.contentMode = .fit
      default:
        self.contentMode = .fill
      }
    }

    if let ratio = options?["aspectRatio"]?.doubleValue {
      self.aspectRatio = CGFloat(1 / ratio)
    }

    // Poster image URL
    if let posterString = options?["posterImage"]?.stringValue, !autoPlay {
      self.showOverlay = true
      self.posterImageURL = URL(string: posterString)
    } else {
      self.showOverlay = false
    }
  }

  var body: some View {
    Group {
      if let videoURL = videoURL {
        VideoPlayer(player: player)
          .onAppear {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity =
              self.contentMode == .fill ? .resizeAspectFill : .resizeAspect
            player?.isMuted = muted

            if loop {
              NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main
              ) { [self] _ in
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
              }
            }

            if autoPlay {
              self.showOverlay = false
              player?.play()
            }
          }
          .onDisappear {
            player?.pause()
            player = nil
          }
          .aspectRatio(aspectRatio, contentMode: self.contentMode)
          .overlay(
            Group {
              if showOverlay {
                // Background for the poster image
                Rectangle().fill(Color.clear)
                  .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
                  .background(
                    AsyncImage(url: self.posterImageURL) { phase in
                      switch phase {
                      case .empty:
                        ProgressView()
                      case .success(let image):
                        image.resizable()
                          .aspectRatio(contentMode: self.contentMode)
                          .clipped()
                      case .failure:
                        EmptyView()
                      @unknown default:
                        EmptyView()
                      }
                    }
                  )
                  .overlay(  // Play button overlay
                    Button(action: {
                      self.player?.play()
                      self.showOverlay = false
                      self.isPlaying = true
                    }) {
                      Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    }
                  )
              }
            }
          )
          .onChange(of: muted) { newMuted in
            player?.isMuted = newMuted
          }

      } else {
        // If no video URL, display poster image or an empty view
        EmptyView()
      }
    }
  }
}
