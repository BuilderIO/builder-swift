//
//  SwiftUIView.swift
//  
//
//  Created by ANSK Vivek on 17/11/22.
//

import SwiftUI
import AVKit
import SwiftyJSON
import AVFoundation


@available(iOS 15.0, macOS 10.15, *)
struct BuilderVideo: View {
    
    var videoURLString = ""
    var player = AVPlayer()
    private let playerLayer = AVPlayerLayer()

    var responsiveStyles: BuilderBlockResponsiveStyles? = BuilderBlockResponsiveStyles() // for outer style of the component
//    var componentDict: [String:BuilderBlockFactory] = [:]
    var options: JSON?
    
    var body: some View {
        
        let textAlignValue = getStyleValue("textAlign")
        let marginLeft = getFloatValue(cssString:getStyleValue("marginLeft") ?? "0px") ?? 0
        let marginTop = getFloatValue(cssString:getStyleValue("marginTop") ?? "0px") ?? 0
        let marginRight = getFloatValue(cssString:getStyleValue("marginRight") ?? "0px") ?? 0
        let marginBottom = getFloatValue(cssString:getStyleValue("marginBottom") ?? "0px") ?? 0
        let cornerRadius = getFloatValue(cssString:getStyleValue("borderRadius") ?? "0px") ?? 0
        let fontWeight = getFontWeight(weight: Int(getFloatValue(cssString:getStyleValue("fontWeight") ?? "300") ?? 30))
        let fontSize = getFloatValue(cssString:getStyleValue("fontSize") ?? "20.0") ?? 0

//        let displayValue = getStyleValue("display")
//        let flexDirection = getStyleValue("flexDirection")
//        let position = getStyleValue("position")
//        let flexShrink = getStyleValue("flexShrink")
//        let boxSizing = getStyleValue("boxSizing")
//        let marginTop = getStyleValue("marginTop")
//        let appearance = getStyleValue("appearance")
//        let color = getStyleValue("color")
//        let cursor = getStyleValue("cursor")
//        let width = getStyleValue("width")
//        let alignSelf = getStyleValue("alignSelf")
        
        let alignmentPosition = ((options?["position"] as? NSString)) as? String ?? ""
        let autoPlay = options?["autoPlay"].boolValue ?? false
        let frameWidth = getFloatValue(cssString: getStyleValue("width") ?? "20px") ?? 0
        let frameHeight = getFloatValue(cssString: getStyleValue("height") ?? "20px") ?? 0
        let minFrameWidth = getFloatValue(cssString: getStyleValue("minWidth") ?? "20px") ?? 0
        let minFrameHeight = getFloatValue(cssString: getStyleValue("minHeight") ?? "20px") ?? 0
        
        let aspectRatio = options?["aspectratio"].floatValue ?? 1
        VStack {
//            VideoPlayer(player: player)
            PlayerView(url: options?["video"])
//                .onAppear {
//                    // Setup the player
//                    if player.currentItem == nil {
//                        if let url = URL(string: videoURLString.trimURLString) {
//                            let item = AVPlayerItem(url: url)
//                            player.replaceCurrentItem(with: item)
//                            
//                            
//                            playerLayer.player = player
//                            playerLayer.videoGravity = .resizeAspectFill
//                            layer.addSublayer(playerLayer)
//                        }
//                    }
//                    if autoPlay == true {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                            // Start the movie
//                            player.play()
//                        })
//                    }
//                    
//                    // Setup looping
//                    player.actionAtItemEnd = .none
//                    NotificationCenter.default.addObserver(self,
//                                                           selector: #selector(playerItemDidReachEnd(notification:)),
//                                                           name: .AVPlayerItemDidPlayToEndTime,
//                                                           object: player.currentItem)
//                    
//                }
            // width/height = 0.7004048582995948
//                .frame(width: UIScreen.main.bounds.size.width, height: (211), alignment: getAlignment(position: (alignmentPosition)))
                .frame(minWidth: minFrameWidth, idealWidth: frameWidth, maxWidth: frameWidth, minHeight: minFrameHeight, idealHeight: frameHeight, maxHeight: frameHeight, alignment: .center)
//                .frame(width: frameWidth, height: frameHeight, alignment: .center)
//                .frame(alignment: .center)
                .padding(EdgeInsets(top: getDirectionStyleValue("padding", "Top"), leading: getDirectionStyleValue("padding", "Left"), bottom: getDirectionStyleValue("padding", "Bottom"), trailing: getDirectionStyleValue("padding", "Right"))) // padding
                .foregroundColor(getColor(propertyName: "color"))
                .background(RoundedRectangle(cornerRadius: cornerRadius).fill(getColor(propertyName: "backgroundColor") ?? .white))
                .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
                .font(.system(size: fontSize, weight: fontWeight, design: .default))
                .aspectRatio(contentMode: .fit)
            
        }
        .padding(EdgeInsets(top: marginTop, leading: marginLeft, bottom: marginBottom, trailing: marginRight)) // margin
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(.white))

    }
    
    func getAlignment(position:String) -> Alignment {
        var alignment:Alignment?
        if position == "left" {
            alignment = .leading
        }
        else if position == "right" {
            alignment = .trailing
        }
        else if position == "center" {
            alignment = .center
        }
        else if position == "top" {
            alignment = .top
        }
        else if position == "bottom" {
            alignment = .bottom
        }
        return alignment ?? .center
    }
    
    func getColor(propertyName: String) -> Color? {
        let value = getStyles()?[propertyName]
        if value != nil {
            if value == "red" {
                return Color.red
            } else if value == "blue" {
                return Color.blue
            } else if value == "white" {
                return Color.white
            } else if value == "gray" {
                return Color.gray
            } else if value == "black" {
                return Color.black
            }
            
            
            let allMatches = matchingStrings(string: value!, regex: "rgba\\((\\d+),\\s*(\\d+),\\s*(\\d+),\\s*(\\d+)\\)");
            if allMatches.count>0 {
                let matches = allMatches[0]
                
                if (matches.count > 3) {
                    return Color(red: Double(matches[1])! / 255, green: Double(matches[2])! / 255, blue: Double(matches[3])! / 255, opacity: Double(matches[4])!)
                }
            }
        } else {
            return Color.white
        }
        return nil
    }
    
    func getStyleValue(_ property: String) -> String? {
        let styles = getStyles()
        return styles?[property]
    }
    
    func getDirectionStyleValue(_ type: String, _ direction: String) -> CGFloat {
        let styles = getStyles()
        var paddingStr = styles?[type + direction]
        if (paddingStr == nil) {
            paddingStr = styles?[type] // TODO: handle muti value padding shorthand
        }
        if (paddingStr != nil) {
            if let num = getFloatValue(cssString: paddingStr!) {
                return num
            }
        }
        
        return 0
    }
    
    func getStyles() -> [String:String]? {
        let step1 = (responsiveStyles?.large ?? [:]).merging(responsiveStyles?.medium ?? [:]) { (_, new) in new }
        let step2 = step1.merging(responsiveStyles?.small ?? [:]) { (_, new) in new }
        
        return step2
    }
    
    func matchingStrings(string: String, regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = string as NSString
        let results  = regex.matches(in: string, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
}

extension String {
    var alphanumeric: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }

    var trimURLString: String {
        return self.replacingOccurrences(of: "\\", with: "")
    }
}

//struct BuilderVideo_Previews: PreviewProvider {
//    @available(iOS 15.0, *)
//    static var previews: some View {
//        if #available(iOS 15.0, *) {
//            BuilderVideo()
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//}

@available(iOS 13.0, *)
struct PlayerView: UIViewRepresentable {
    
    var url:URL?
    
    @available(iOS 13.0, *)
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero, url: url)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, url:URL?) {
        super.init(frame: frame)
        
        // Setup the player
        let player = AVPlayer(url: url!)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        // Start the movie
        player.play()
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
