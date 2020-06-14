import AppKit
import Combine

final class Bar: NSView {
    private weak var base: NSView!
    private weak var border: NSView!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        
        let play = Button(image: "play")
        play.target = state
        play.action = #selector(state.play)
        addSubview(play)
        
        let pause = Button(image: "pause")
        pause.target = state
        pause.action = #selector(state.pause)
        addSubview(pause)
        
        let previous = Button(image: "previous")
        previous.target = state
        previous.action = #selector(state.previous)
        addSubview(previous)
        
        let next = Button(image: "next")
        next.target = state
        next.action = #selector(state.next)
        addSubview(next)
        
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
        
        let totalTime = Label("", .monospaced(.medium(11)))
        totalTime.textColor = .secondaryLabelColor
        totalTime.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        base.addSubview(totalTime)
        
        let currentTime = Label("", .monospaced(.regular(11)))
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
        
        play.rightAnchor.constraint(equalTo: next.leftAnchor, constant: -10).isActive = true
        play.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pause.centerXAnchor.constraint(equalTo: play.centerXAnchor).isActive = true
        pause.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        previous.rightAnchor.constraint(equalTo: play.leftAnchor, constant: -10).isActive = true
        previous.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        next.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        next.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
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
        
        state.player.track.sink {
            title.stringValue = .key($0.composer.name) + " - " + .key($0.title)
            totalTime.stringValue = formatter.string(from: state.player.track.value.duration)!
        }.store(in: &subs)
        
        state.time.sink {
            currentTime.stringValue = formatter.string(from: $0)!
        }.store(in: &subs)
        
        state.playing.sink {
            play.isHidden = $0
            pause.isHidden = !$0
        }.store(in: &subs)
        
        state.player.nextable.sink {
            next.enabled = $0
        }.store(in: &subs)
        
        state.player.previousable.sink {
            previous.enabled = $0
        }.store(in: &subs)
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlHighlightColor.cgColor
        border.layer!.backgroundColor = NSColor.controlLightHighlightColor.cgColor
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
