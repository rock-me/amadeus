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
        
        let close = Close()
        close.target = self
        close.action = #selector(done)
        view.addSubview(close)
        
        let randomTitle = UILabel()
        randomTitle.translatesAutoresizingMaskIntoConstraints = false
        randomTitle.text = .key("Random")
        randomTitle.font = .regular(-2)
        randomTitle.textColor = .secondaryLabel
        scroll.add(randomTitle)
        
        let randomSeparator = Separator()
        randomSeparator.backgroundColor = .secondarySystemGroupedBackground
        scroll.add(randomSeparator)
        
        let random = UISegmentedControl(items: [String.key("Off"), .key("Track"), .key("Album")])
        random.translatesAutoresizingMaskIntoConstraints = false
        random.addTarget(self, action: #selector(self.random), for: .valueChanged)
        random.selectedSegmentTintColor = .systemBlue
        scroll.add(random)
        
        let trackTitle = UILabel()
        trackTitle.translatesAutoresizingMaskIntoConstraints = false
        trackTitle.font = .regular(-2)
        trackTitle.text = .key("When.track.finishes")
        trackTitle.textColor = .secondaryLabel
        scroll.add(trackTitle)
        
        let trackSeparator = Separator()
        trackSeparator.backgroundColor = randomSeparator.backgroundColor
        scroll.add(trackSeparator)
        
        let track = UISegmentedControl(items: [String.key("Stop"), .key("Loop"), .key("Next")])
        track.translatesAutoresizingMaskIntoConstraints = false
        track.addTarget(self, action: #selector(self.track), for: .valueChanged)
        track.selectedSegmentTintColor = .systemBlue
        scroll.add(track)
        
        let albumTitle = UILabel()
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        albumTitle.font = .regular(-2)
        albumTitle.text = .key("When.album.finishes")
        albumTitle.textColor = .secondaryLabel
        scroll.add(albumTitle)
        
        let albumSeparator = Separator()
        albumSeparator.backgroundColor = randomSeparator.backgroundColor
        scroll.add(albumSeparator)
        
        let album = UISegmentedControl(items: [String.key("Stop"), .key("Loop"), .key("Next")])
        album.translatesAutoresizingMaskIntoConstraints = false
        album.addTarget(self, action: #selector(self.album), for: .valueChanged)
        album.selectedSegmentTintColor = .systemBlue
        scroll.add(album)
        
        let notificationsSeparator = Separator()
        notificationsSeparator.backgroundColor = randomSeparator.backgroundColor
        scroll.add(notificationsSeparator)
        
        let notificationsTitle = UILabel()
        notificationsTitle.translatesAutoresizingMaskIntoConstraints = false
        notificationsTitle.text = .key("Notify.on.track")
        notificationsTitle.font = .regular(-2)
        notificationsTitle.textColor = .secondaryLabel
        scroll.add(notificationsTitle)
        
        let notifications = UISwitch()
        notifications.translatesAutoresizingMaskIntoConstraints = false
        notifications.addTarget(self, action: #selector(self.notifications), for: .valueChanged)
        notifications.onTintColor = .systemBlue
        scroll.add(notifications)
        
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: notificationsSeparator.bottomAnchor, constant: 30).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        
        close.topAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        close.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        
        randomTitle.leftAnchor.constraint(equalTo: random.leftAnchor, constant: 20).isActive = true
        randomTitle.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 20).isActive = true
        
        randomSeparator.topAnchor.constraint(equalTo: randomTitle.bottomAnchor, constant: 5).isActive = true
        randomSeparator.bottomAnchor.constraint(equalTo: random.bottomAnchor, constant: 10).isActive = true
        randomSeparator.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        randomSeparator.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        random.topAnchor.constraint(equalTo: randomSeparator.topAnchor, constant: 10).isActive = true
        random.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        random.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        trackTitle.leftAnchor.constraint(equalTo: track.leftAnchor, constant: 20).isActive = true
        trackTitle.topAnchor.constraint(equalTo: randomSeparator.bottomAnchor, constant: 30).isActive = true
        
        trackSeparator.topAnchor.constraint(equalTo: trackTitle.bottomAnchor, constant: 5).isActive = true
        trackSeparator.bottomAnchor.constraint(equalTo: track.bottomAnchor, constant: 10).isActive = true
        trackSeparator.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        trackSeparator.rightAnchor.constraint(equalTo: scroll.right).isActive = true

        track.topAnchor.constraint(equalTo: trackSeparator.topAnchor, constant: 10).isActive = true
        track.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        track.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        albumTitle.leftAnchor.constraint(equalTo: album.leftAnchor, constant: 20).isActive = true
        albumTitle.topAnchor.constraint(equalTo: trackSeparator.bottomAnchor, constant: 30).isActive = true
        
        albumSeparator.topAnchor.constraint(equalTo: albumTitle.bottomAnchor, constant: 5).isActive = true
        albumSeparator.bottomAnchor.constraint(equalTo: album.bottomAnchor, constant: 10).isActive = true
        albumSeparator.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        albumSeparator.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        album.topAnchor.constraint(equalTo: albumSeparator.topAnchor, constant: 10).isActive = true
        album.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        album.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        notificationsSeparator.topAnchor.constraint(equalTo: albumSeparator.bottomAnchor, constant: 50).isActive = true
        notificationsSeparator.bottomAnchor.constraint(equalTo: notifications.bottomAnchor, constant: 10).isActive = true
        notificationsSeparator.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        notificationsSeparator.rightAnchor.constraint(equalTo: scroll.right).isActive = true

        notificationsTitle.rightAnchor.constraint(equalTo: notifications.leftAnchor, constant: -20).isActive = true
        notificationsTitle.centerYAnchor.constraint(equalTo: notificationsSeparator.centerYAnchor).isActive = true

        notifications.topAnchor.constraint(equalTo: notificationsSeparator.topAnchor, constant: 10).isActive = true
        notifications.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        session.player.config.sink {
            random.selectedSegmentIndex = .init($0.random.rawValue)
            track.selectedSegmentIndex = .init($0.trackEnds.rawValue)
            album.selectedSegmentIndex = .init($0.albumEnds.rawValue)
            track.isEnabled = $0.random == .none
            album.isEnabled = $0.random == .none
            trackTitle.alpha = $0.random == .none ? 1 : 0.3
            albumTitle.alpha = $0.random == .none ? 1 : 0.3
            notifications.isOn = $0.notifications
        }.store(in: &subs)
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
