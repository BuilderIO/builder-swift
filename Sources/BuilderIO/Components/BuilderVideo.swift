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
        Rectangle().fill(Color.clear)
          .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
          .if(contentMode == .fill) { view in
            view.background(
              VideoPlayerView(
                videoURL: videoURL,
                autoPlay: true,
                muted: self.muted,
                loop: self.loop
              )
            )
          }
          .if(contentMode == .fit) { view in
            view.background(
              VideoPlayer(player: player)
                .onAppear {
                  player = AVPlayer(url: videoURL)
                  player?.isMuted = muted

                  if loop {
                    NotificationCenter.default.addObserver(
                      forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem,
                      queue: .main
                    ) { [self] _ in
                      self.player?.seek(to: CMTime.zero)
                      self.player?.play()
                    }
                  }

                  if autoPlay {
                    self.showOverlay = false
                    player?.play()
                  }
                }.onDisappear {
                  player?.pause()
                  player = nil
                }

            )
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

      } else {
        // If no video URL, display poster image or an empty view
        EmptyView()
      }
    }
  }
}

struct VideoPlayerView: UIViewRepresentable {
  var videoURL: URL
  var autoPlay: Bool
  var muted: Bool
  var loop: Bool

  func makeUIView(context: Context) -> PlayerContainerView {
    let playerContainerView = PlayerContainerView(
      videoURL: videoURL,
      autoPlay: autoPlay,
      muted: muted,
      loop: loop
    )
    return playerContainerView
  }

  func updateUIView(_ uiView: PlayerContainerView, context: Context) {

    uiView.player?.isMuted = muted

  }

  // 2. Custom UIView subclass to host the AVPlayerLayer
  class PlayerContainerView: UIView {
    var player: AVPlayer?  // Make it optional to handle init scenarios
    private var playerLayer: AVPlayerLayer!
    private var playerLooper: AVPlayerLooper?

    init(videoURL: URL, autoPlay: Bool, muted: Bool, loop: Bool) {
      super.init(frame: .zero)
      self.backgroundColor = .black

      // For seamless looping, use AVPlayerLooper with a queue player
      // This also handles the initial autoPlay.
      let playerItem = AVPlayerItem(url: videoURL)
      let queuePlayer = AVQueuePlayer(playerItem: playerItem)

      player = queuePlayer  // Assign to the optional player property
      playerLayer = AVPlayerLayer(player: queuePlayer)
      playerLayer.videoGravity = .resizeAspectFill

      self.layer.addSublayer(playerLayer)

      // Apply mute setting
      player?.isMuted = muted

      // Handle looping
      if loop {
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
      }

      // Handle autoPlay
      if autoPlay {
        queuePlayer.play()
      }

    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      playerLayer.frame = bounds
    }
  }
}
