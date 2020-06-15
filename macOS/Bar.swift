import AppKit
import Combine

final class Bar: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        
        let title = Label("", .bold(16))
        title.textColor = .headerColor
        addSubview(title)
        
        let composer = Label("", .regular(12))
        composer.textColor = .secondaryLabelColor
        addSubview(composer)
        
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
        
        let progress = NSView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.wantsLayer = true
        progress.layer!.backgroundColor = NSColor.underPageBackgroundColor.cgColor
        progress.layer!.cornerRadius = 3
        addSubview(progress)
        
        let elapsed = NSView()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.wantsLayer = true
        elapsed.layer!.backgroundColor = NSColor.systemBlue.cgColor
        progress.addSubview(elapsed)
        
        let totalTime = Label("", .monospaced(.medium(11)))
        totalTime.textColor = .tertiaryLabelColor
        addSubview(totalTime)
        
        let currentTime = Label("", .monospaced(.regular(11)))
        currentTime.textColor = .tertiaryLabelColor
        addSubview(currentTime)
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        composer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        play.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        play.topAnchor.constraint(equalTo: composer.bottomAnchor, constant: 20).isActive = true
        
        pause.centerXAnchor.constraint(equalTo: play.centerXAnchor).isActive = true
        pause.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        
        previous.rightAnchor.constraint(equalTo: play.leftAnchor, constant: -10).isActive = true
        previous.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        
        next.leftAnchor.constraint(equalTo: play.rightAnchor, constant: 10).isActive = true
        next.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        
        progress.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        progress.widthAnchor.constraint(equalToConstant: 150).isActive = true
        progress.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        elapsed.leftAnchor.constraint(equalTo: progress.leftAnchor).isActive = true
        elapsed.topAnchor.constraint(equalTo: progress.topAnchor).isActive = true
        elapsed.bottomAnchor.constraint(equalTo: progress.bottomAnchor).isActive = true
        let width = elapsed.widthAnchor.constraint(equalToConstant: 0)
        width.isActive = true
        
        currentTime.rightAnchor.constraint(equalTo: progress.leftAnchor, constant: -10).isActive = true
        currentTime.centerYAnchor.constraint(equalTo: progress.centerYAnchor, constant: -1).isActive = true
        
        totalTime.leftAnchor.constraint(equalTo: progress.rightAnchor, constant: 10).isActive = true
        totalTime.centerYAnchor.constraint(equalTo: progress.centerYAnchor, constant: -1).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        layoutSubtreeIfNeeded()
        
        state.player.track.sink {
            title.stringValue = .key($0.title)
            composer.stringValue = .key($0.composer.name)
            totalTime.stringValue = formatter.string(from: state.player.track.value.duration)!
        }.store(in: &subs)
        
        state.time.sink {
            currentTime.stringValue = formatter.string(from: $0)!
            width.constant = 150 * .init($0 / state.player.track.value.duration)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                progress.layoutSubtreeIfNeeded()
            }
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
        image.imageScaling = .scaleNone
        addSubview(image)
        self.image = image
        
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 22).isActive = true
        image.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        hoverOff()
    }
    
    override func hoverOn() {
        image.contentTintColor = .systemBlue
    }
    
    override func hoverOff() {
        image.contentTintColor = .controlTextColor
    }
}
