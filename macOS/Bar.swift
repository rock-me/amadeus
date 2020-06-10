import AppKit
import Combine

final class Bar: NSView {
    private weak var base: NSView!
    private weak var border: NSView!
    private var subs = Set<AnyCancellable>()
    private let formatter = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.allowedUnits = [.minute, .second]
        
        let playButton = Button(image: "play")
        playButton.target = self
        playButton.action = #selector(play)
        addSubview(playButton)
        
        let pauseButton = Button(image: "pause")
        pauseButton.target = self
        pauseButton.action = #selector(pause)
        pauseButton.isHidden = true
        addSubview(pauseButton)
        
        let previousButton = Button(image: "previous")
        previousButton.target = self
        previousButton.action = #selector(previous)
        addSubview(previousButton)
        
        let nextButton = Button(image: "next")
        nextButton.target = self
        nextButton.action = #selector(next)
        addSubview(nextButton)
        
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
        
        let totalTime = Label("", NSFont(descriptor: NSFont.medium(11).fontDescriptor.addingAttributes([
        .featureSettings: [[NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                            .typeIdentifier: kNumberSpacingType]]]), size: 0)!)
        totalTime.textColor = .secondaryLabelColor
        totalTime.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        base.addSubview(totalTime)
        
        let currentTime = Label("", NSFont(descriptor: NSFont.regular(11).fontDescriptor.addingAttributes([
        .featureSettings: [[NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                            .typeIdentifier: kNumberSpacingType]]]), size: 0)!)
        currentTime.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        base.addSubview(currentTime)
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 24).isActive = true
        base.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        
        border.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        playButton.rightAnchor.constraint(equalTo: nextButton.leftAnchor, constant: -10).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pauseButton.centerXAnchor.constraint(equalTo: playButton.centerXAnchor).isActive = true
        pauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        previousButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -10).isActive = true
        previousButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        nextButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: currentTime.leftAnchor, constant: -10).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        totalTime.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        totalTime.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        currentTime.rightAnchor.constraint(equalTo: totalTime.leftAnchor).isActive = true
        currentTime.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        session.player.track.sink {
            title.stringValue = .key($0.composer.name) + " - " + .key($0.title)
            totalTime.stringValue = self.formatter.string(from: session.player.track.value.duration)!
        }.store(in: &subs)
        
        session.time.sink {
            currentTime.stringValue = self.formatter.string(from: $0)!
        }.store(in: &subs)
        
        session.playing.sink {
            playButton.isHidden = $0
            pauseButton.isHidden = !$0
        }.store(in: &subs)
        
        session.player.nextable.sink {
            nextButton.enabled = $0
        }.store(in: &subs)
        
        session.player.previousable.sink {
            previousButton.enabled = $0
        }.store(in: &subs)
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlHighlightColor.cgColor
        border.layer!.backgroundColor = NSColor.controlLightHighlightColor.cgColor
    }
    
    @objc private func play() {
        session.play()
    }
    
    @objc private func pause() {
        session.pause()
    }
    
    @objc private func previous() {
        session.previous()
    }
    
    @objc private func next() {
        session.next()
    }
}

private final class Button: Control {
    override var enabled: Bool {
        didSet {
            alphaValue = enabled ? 1 : 0.3
        }
    }
    
    private weak var image: NSImageView!
    
    required init?(coder: NSCoder) { nil }
    init(image: String) {
        super.init()
        
        let image = NSImageView(image: NSImage(named: image)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .controlTextColor
        image.imageScaling = .scaleNone
        addSubview(image)
        self.image = image
        
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 22).isActive = true
        image.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    override func hoverOn() {
        image.contentTintColor = .controlAccentColor
    }
    
    override func hoverOff() {
        image.contentTintColor = .controlTextColor
    }
}
