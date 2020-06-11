import UIKit
import Combine

final class Hud: UIViewController {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        
        let current = Current()
        current.selector.backgroundColor = .tertiarySystemBackground
        view.addSubview(current)
        
        let close = Control()
        close.target = self
        close.action = #selector(done)
        view.addSubview(close)
        
        let play = Button(icon: "play.circle.fill", padding: 0)
        play.target = session
        play.action = #selector(session.play)
        view.addSubview(play)
        
        let pause = Button(icon: "pause.circle.fill", padding: 0)
        pause.target = session
        pause.action = #selector(session.pause)
        view.addSubview(pause)
        
        let previous = Button(icon: "backward.end.fill", padding: 15)
        previous.target = session
        previous.action = #selector(session.previous)
        view.addSubview(previous)
        
        let next = Button(icon: "forward.end.fill", padding: 15)
        next.target = session
        next.action = #selector(session.next)
        view.addSubview(next)
        
        let duration = UIView()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.isUserInteractionEnabled = false
        duration.backgroundColor = .secondarySystemFill
        duration.layer.cornerRadius = 3
        view.addSubview(duration)
        
        let elapsed = UIView()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.isUserInteractionEnabled = false
        elapsed.backgroundColor = .systemBlue
        elapsed.layer.cornerRadius = 3
        view.addSubview(elapsed)
        
        let total = UILabel()
        total.translatesAutoresizingMaskIntoConstraints = false
        total.font = .monospaced(.medium(-3))
        total.textColor = .secondaryLabel
        view.addSubview(total)
        
        let time = UILabel()
        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = .monospaced(.regular(-3))
        view.addSubview(time)
        
        current.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        current.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        current.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        close.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        close.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: current.selector.bottomAnchor, constant: 30).isActive = true
        
        play.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        play.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        play.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        pause.centerXAnchor.constraint(equalTo: play.centerXAnchor).isActive = true
        pause.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        pause.widthAnchor.constraint(equalTo: play.widthAnchor).isActive = true
        
        previous.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        previous.rightAnchor.constraint(equalTo: play.leftAnchor, constant: -20).isActive = true
        previous.widthAnchor.constraint(equalToConstant: 54).isActive = true
        
        next.centerYAnchor.constraint(equalTo: play.centerYAnchor).isActive = true
        next.leftAnchor.constraint(equalTo: play.rightAnchor, constant: 20).isActive = true
        next.widthAnchor.constraint(equalTo: previous.widthAnchor).isActive = true
        
        duration.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        duration.heightAnchor.constraint(equalToConstant: 6).isActive = true
        duration.widthAnchor.constraint(equalToConstant: 200).isActive = true
        duration.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        elapsed.leftAnchor.constraint(equalTo: duration.leftAnchor).isActive = true
        elapsed.topAnchor.constraint(equalTo: duration.topAnchor).isActive = true
        elapsed.bottomAnchor.constraint(equalTo: duration.bottomAnchor).isActive = true
        let width = elapsed.widthAnchor.constraint(equalToConstant: 0)
        width.isActive = true
        
        total.rightAnchor.constraint(equalTo: duration.rightAnchor).isActive = true
        total.bottomAnchor.constraint(equalTo: duration.topAnchor, constant: -2).isActive = true
        
        time.leftAnchor.constraint(equalTo: duration.leftAnchor).isActive = true
        time.bottomAnchor.constraint(equalTo: duration.topAnchor, constant: -2).isActive = true
        
        session.player.track.sink { _ in
            total.text = formatter.string(from: session.player.track.value.duration)!
        }.store(in: &subs)
        
        session.time.sink {
            time.text = formatter.string(from: $0)!
            width.constant = 200 * .init($0 / session.player.track.value.duration)
        }.store(in: &subs)
        
        session.playing.sink {
            play.isHidden = $0
            pause.isHidden = !$0
        }.store(in: &subs)
        
        session.player.nextable.sink {
            next.enabled = $0
        }.store(in: &subs)
        
        session.player.previousable.sink {
            previous.enabled = $0
        }.store(in: &subs)
    }
    
    @objc private func done() {
        dismiss(animated: true)
    }
}

private final class Button: Control {
    var enabled = true {
        didSet {
            isUserInteractionEnabled = enabled
            hoverOff()
        }
    }
    
    private weak var image: UIImageView!
    
    required init?(coder: NSCoder) { nil }
    init(icon: String, padding: CGFloat) {
        super.init()
        let image = UIImageView(image: UIImage(systemName: icon)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        self.image = image
        
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding).isActive = true
        
        hoverOff()
    }
    
    override func hoverOff() {
        image.tintColor = enabled ? .label : .tertiaryLabel
    }
    
    override func hoverOn() {
        image.tintColor = enabled ? .systemBlue : .tertiaryLabel
    }
}
