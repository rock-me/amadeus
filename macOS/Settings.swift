import AppKit
import Player
import Combine

final class Settings: NSWindow {
    private var subs = Set<AnyCancellable>()
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 350, height: 400), styleMask:
            [.borderless, .miniaturizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        center()
        
        let randomTitle = Label(.key("Random"), .regular())
        contentView!.addSubview(randomTitle)
        
        let random = NSPopUpButton(frame: .zero)
        random.translatesAutoresizingMaskIntoConstraints = false
        random.addItems(withTitles: [.key("Off"), .key("Track"), .key("Album")])
        random.target = self
        random.action = #selector(self.random)
        contentView!.addSubview(random)
        
        let randomSeparator = Separator()
        contentView!.addSubview(randomSeparator)
        
        let trackTitle = Label(.key("When.track.finishes"), .regular())
        contentView!.addSubview(trackTitle)
        
        let track = NSPopUpButton(frame: .zero)
        track.translatesAutoresizingMaskIntoConstraints = false
        track.addItems(withTitles: [.key("Stop"), .key("Loop"), .key("Next")])
        track.target = self
        track.action = #selector(self.track)
        contentView!.addSubview(track)
        
        let trackSeparator = Separator()
        contentView!.addSubview(trackSeparator)
        
        let albumTitle = Label(.key("When.album.finishes"), .regular())
        contentView!.addSubview(albumTitle)
        
        let album = NSPopUpButton(frame: .zero)
        album.translatesAutoresizingMaskIntoConstraints = false
        album.addItems(withTitles: [.key("Stop"), .key("Loop"), .key("Next")])
        album.target = self
        album.action = #selector(self.album)
        contentView!.addSubview(album)
        
        let albumSeparator = Separator()
        contentView!.addSubview(albumSeparator)
        
        let notifications = NSButton(checkboxWithTitle: .key("Notify.on.track"), target: self, action: #selector(self.notifications))
        notifications.translatesAutoresizingMaskIntoConstraints = false
        notifications.font = .regular()
        contentView!.addSubview(notifications)
        
        random.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 70).isActive = true
        random.leftAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: 30).isActive = true
        
        randomTitle.rightAnchor.constraint(equalTo: random.leftAnchor, constant: -20).isActive = true
        randomTitle.centerYAnchor.constraint(equalTo: random.centerYAnchor).isActive = true
        
        randomSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        randomSeparator.topAnchor.constraint(equalTo: random.bottomAnchor, constant: 30).isActive = true
        randomSeparator.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 60).isActive = true
        randomSeparator.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -60).isActive = true
        
        track.topAnchor.constraint(equalTo: randomSeparator.bottomAnchor, constant: 30).isActive = true
        track.leftAnchor.constraint(equalTo: random.leftAnchor).isActive = true
        
        trackTitle.rightAnchor.constraint(equalTo: randomTitle.rightAnchor).isActive = true
        trackTitle.centerYAnchor.constraint(equalTo: track.centerYAnchor).isActive = true
        
        trackSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        trackSeparator.topAnchor.constraint(equalTo: track.bottomAnchor, constant: 30).isActive = true
        trackSeparator.leftAnchor.constraint(equalTo: randomSeparator.leftAnchor).isActive = true
        trackSeparator.rightAnchor.constraint(equalTo: randomSeparator.rightAnchor).isActive = true
        
        album.topAnchor.constraint(equalTo: trackSeparator.bottomAnchor, constant: 30).isActive = true
        album.leftAnchor.constraint(equalTo: random.leftAnchor).isActive = true
        
        albumTitle.rightAnchor.constraint(equalTo: randomTitle.rightAnchor).isActive = true
        albumTitle.centerYAnchor.constraint(equalTo: album.centerYAnchor).isActive = true
        
        albumSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        albumSeparator.topAnchor.constraint(equalTo: album.bottomAnchor, constant: 30).isActive = true
        albumSeparator.leftAnchor.constraint(equalTo: randomSeparator.leftAnchor).isActive = true
        albumSeparator.rightAnchor.constraint(equalTo: randomSeparator.rightAnchor).isActive = true
        
        notifications.topAnchor.constraint(equalTo: albumSeparator.bottomAnchor, constant: 32).isActive = true
        notifications.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        state.player.config.sink {
            random.selectItem(at: .init($0.random.rawValue))
            track.selectItem(at: .init($0.trackEnds.rawValue))
            album.selectItem(at: .init($0.albumEnds.rawValue))
            track.isEnabled = $0.random == .none
            album.isEnabled = $0.random == .none
            trackTitle.alphaValue = $0.random == .none ? 1 : 0.3
            albumTitle.alphaValue = $0.random == .none ? 1 : 0.3
            notifications.state = $0.notifications ? .on : .off
        }.store(in: &subs)
    }
    
    @objc private func random(_ button: NSPopUpButton) {
        state.player.config.value.random = Random(rawValue: .init(button.indexOfSelectedItem))!
    }
    
    @objc private func track(_ button: NSPopUpButton) {
        state.player.config.value.trackEnds = Heuristic(rawValue: .init(button.indexOfSelectedItem))!
    }
    
    @objc private func album(_ button: NSPopUpButton) {
        state.player.config.value.albumEnds = Heuristic(rawValue: .init(button.indexOfSelectedItem))!
    }
    
    @objc private func notifications(_ button: NSButton) {
        state.player.config.value.notifications = button.state == .on
    }
}
