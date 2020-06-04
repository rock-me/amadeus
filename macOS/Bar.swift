import AppKit
import Combine

final class Bar: NSView {
    private weak var controls: NSView!
    private weak var base: NSView!
    private weak var border: NSView!
    private weak var playButton: Button!
    private weak var pauseButton: Button!
    private var subs = Set<AnyCancellable>()
    private let formatter = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.allowedUnits = [.minute, .second]
        
        let controls = NSView()
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.wantsLayer = true
        controls.layer!.cornerRadius = 13
        addSubview(controls)
        self.controls = controls
        
        let playButton = Button(image: "play")
        playButton.target = self
        playButton.action = #selector(play)
        controls.addSubview(playButton)
        self.playButton = playButton
        
        let pauseButton = Button(image: "pause")
        pauseButton.target = self
        pauseButton.action = #selector(pause)
        pauseButton.isHidden = true
        controls.addSubview(pauseButton)
        self.pauseButton = pauseButton
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        base.addSubview(border)
        self.border = border
        
        let title = Label("", .regular(11))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        title.textColor = .secondaryLabelColor
        base.addSubview(title)
        
        let time = Label("", NSFont(descriptor: NSFont.regular(11).fontDescriptor.addingAttributes([
        .featureSettings: [[NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                            .typeIdentifier: kNumberSpacingType]]]), size: 0)!)
        time.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        base.addSubview(time)
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 24).isActive = true
        base.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.4).isActive = true
        
        border.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        controls.rightAnchor.constraint(equalTo: base.leftAnchor, constant: -10).isActive = true
        controls.heightAnchor.constraint(equalToConstant: 26).isActive = true
        controls.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        controls.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 80).isActive = true
        controls.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        let controlsWidth = controls.widthAnchor.constraint(equalToConstant: 150)
        controlsWidth.priority = .defaultLow
        controlsWidth.isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: controls.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: controls.centerYAnchor).isActive = true
        
        pauseButton.centerXAnchor.constraint(equalTo: controls.centerXAnchor).isActive = true
        pauseButton.centerYAnchor.constraint(equalTo: controls.centerYAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        time.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        player.sink {
            title.stringValue = .key("track_\($0.track)_composer") + " - " + .key("track_\($0.track)_title")
            time.stringValue = self.formatter.string(from: $0.elapsed)! + " / " + self.formatter.string(from: $0.track.duration)!
            playButton.isHidden = $0.playing
            pauseButton.isHidden = !$0.playing
        }.store(in: &subs)
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlHighlightColor.cgColor
        border.layer!.backgroundColor = NSColor.controlLightHighlightColor.cgColor
        controls.layer!.backgroundColor = NSColor.underPageBackgroundColor.cgColor
    }
    
    @objc private func play() {
        player.play()
    }
    
    @objc private func pause() {
        player.pause()
    }
}

private final class Button: Control {
    private weak var image: NSImageView!
    
    required init?(coder: NSCoder) { nil }
    init(image: String) {
        super.init()
        
        let image = NSImageView(image: NSImage(named: image)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .highlightColor
        addSubview(image)
        self.image = image
        
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 16).isActive = true
        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    override func hoverOn() {
        image.contentTintColor = .textColor
    }
    
    override func hoverOff() {
        image.contentTintColor = .highlightColor
    }
}
