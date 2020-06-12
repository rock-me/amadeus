import UIKit
import Player
import Combine

final class Settings: UIViewController {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let scroll = Scroll()
        scroll.alwaysBounceVertical = true
        scroll.alwaysBounceHorizontal = false
        scroll.showsVerticalScrollIndicator = true
        view.addSubview(scroll)
        
        let randomTitle = UILabel()
        randomTitle.translatesAutoresizingMaskIntoConstraints = false
        randomTitle.text = .key("Random")
        randomTitle.font = .regular()
        randomTitle.textColor = .secondaryLabel
        view.addSubview(randomTitle)
        
        let random = UISegmentedControl(items: [String.key("Off"), .key("Track"), .key("Album")])
        random.translatesAutoresizingMaskIntoConstraints = false
        random.addTarget(self, action: #selector(self.random), for: .valueChanged)
        view.addSubview(random)
        
        let randomSeparator = Separator()
        view.addSubview(randomSeparator)
        
        let trackTitle = UILabel()
        trackTitle.translatesAutoresizingMaskIntoConstraints = false
        trackTitle.font = .regular()
        trackTitle.text = .key("When.track.finishes")
        trackTitle.textColor = .secondaryLabel
        view.addSubview(trackTitle)
        
        let track = UISegmentedControl(items: [String.key("Stop"), .key("Loop"), .key("Next")])
        track.translatesAutoresizingMaskIntoConstraints = false
        track.addTarget(self, action: #selector(self.track), for: .valueChanged)
        view.addSubview(track)
        
        let trackSeparator = Separator()
        view.addSubview(trackSeparator)
        
        let albumTitle = UILabel()
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        albumTitle.font = .regular()
        albumTitle.text = .key("When.album.finishes")
        view.addSubview(albumTitle)
        
        let album = UISegmentedControl(items: [String.key("Stop"), .key("Loop"), .key("Next")])
        album.translatesAutoresizingMaskIntoConstraints = false
        album.addTarget(self, action: #selector(self.album), for: .valueChanged)
        view.addSubview(album)
        
        let albumSeparator = Separator()
        view.addSubview(albumSeparator)
        
        let notificationsTitle = UILabel()
        notificationsTitle.translatesAutoresizingMaskIntoConstraints = false
        notificationsTitle.text = .key("Notify.on.track")
        notificationsTitle.font = .regular()
        view.addSubview(notificationsTitle)
        
        let notifications = UISwitch()
        notifications.translatesAutoresizingMaskIntoConstraints = false
        notifications.addTarget(self, action: #selector(self.notifications), for: .valueChanged)
        view.addSubview(notifications)
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: notifications.bottomAnchor, constant: 40).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        
        randomTitle.leftAnchor.constraint(equalTo: random.leftAnchor, constant: 20).isActive = true
        randomTitle.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        
        random.topAnchor.constraint(equalTo: randomTitle.bottomAnchor, constant: 20).isActive = true
        random.centerXAnchor.constraint(equalTo: scroll.centerX, constant: 30).isActive = true
        
        
        
//        randomSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        randomSeparator.topAnchor.constraint(equalTo: random.bottomAnchor, constant: 30).isActive = true
//        randomSeparator.leftAnchor.constraint(equalTo: centerXAnchor, constant: -170).isActive = true
//        randomSeparator.rightAnchor.constraint(equalTo: centerXAnchor, constant: 170).isActive = true
//
//        track.topAnchor.constraint(equalTo: randomSeparator.bottomAnchor, constant: 30).isActive = true
//        track.leftAnchor.constraint(equalTo: random.leftAnchor).isActive = true
//
//        trackTitle.rightAnchor.constraint(equalTo: randomTitle.rightAnchor).isActive = true
//        trackTitle.centerYAnchor.constraint(equalTo: track.centerYAnchor).isActive = true
//
//        trackSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        trackSeparator.topAnchor.constraint(equalTo: track.bottomAnchor, constant: 30).isActive = true
//        trackSeparator.leftAnchor.constraint(equalTo: randomSeparator.leftAnchor).isActive = true
//        trackSeparator.rightAnchor.constraint(equalTo: randomSeparator.rightAnchor).isActive = true
//
//        album.topAnchor.constraint(equalTo: trackSeparator.bottomAnchor, constant: 30).isActive = true
//        album.leftAnchor.constraint(equalTo: random.leftAnchor).isActive = true
//
//        albumTitle.rightAnchor.constraint(equalTo: randomTitle.rightAnchor).isActive = true
//        albumTitle.centerYAnchor.constraint(equalTo: album.centerYAnchor).isActive = true
//
//        albumSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        albumSeparator.topAnchor.constraint(equalTo: album.bottomAnchor, constant: 30).isActive = true
//        albumSeparator.leftAnchor.constraint(equalTo: randomSeparator.leftAnchor).isActive = true
//        albumSeparator.rightAnchor.constraint(equalTo: randomSeparator.rightAnchor).isActive = true
//
//        notifications.topAnchor.constraint(equalTo: albumSeparator.bottomAnchor, constant: 32).isActive = true
//        notifications.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//
//        session.player.config.sink {
//            random.selectItem(at: .init($0.random.rawValue))
//            track.selectItem(at: .init($0.trackEnds.rawValue))
//            album.selectItem(at: .init($0.albumEnds.rawValue))
//            track.isEnabled = $0.random == .none
//            album.isEnabled = $0.random == .none
//            trackTitle.alphaValue = $0.random == .none ? 1 : 0.3
//            albumTitle.alphaValue = $0.random == .none ? 1 : 0.3
//            notifications.state = $0.notifications ? .on : .off
//        }.store(in: &subs)
    }
    
    @objc private func random(_ segmented: UISegmentedControl) {
        session.player.config.value.random = Random(rawValue: .init(segmented.selectedSegmentIndex))!
    }
    
    @objc private func track(_ segmented: UISegmentedControl) {
        session.player.config.value.trackEnds = Heuristic(rawValue: .init(segmented.selectedSegmentIndex))!
    }
    
    @objc private func album(_ segmented: UISegmentedControl) {
        session.player.config.value.albumEnds = Heuristic(rawValue: .init(segmented.selectedSegmentIndex))!
    }
    
    @objc private func notifications(_ toggle: UISwitch) {
        session.player.config.value.notifications = toggle.isOn
    }
}
