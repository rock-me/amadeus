import AppKit
import Player
import Combine

final class Settings: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let randomTitle = Label(.key("Random"), .regular(14))
        addSubview(randomTitle)
        
        let random = NSPopUpButton(frame: .zero)
        random.translatesAutoresizingMaskIntoConstraints = false
        random.addItems(withTitles: [.key("Off"), .key("Track"), .key("Album")])
        random.target = self
        random.action = #selector(self.random)
        addSubview(random)
        
        let randomSeparator = Separator()
        addSubview(randomSeparator)
        
        let trackTitle = Label(.key("When.track.finishes"), .regular(14))
        addSubview(trackTitle)
        
        let track = NSPopUpButton(frame: .zero)
        track.translatesAutoresizingMaskIntoConstraints = false
        track.addItems(withTitles: [.key("Stop"), .key("Loop"), .key("Next")])
        track.target = self
        track.action = #selector(self.track)
        addSubview(track)
        
        let trackSeparator = Separator()
        addSubview(trackSeparator)
        
        let albumTitle = Label(.key("When.album.finishes"), .regular(14))
        addSubview(albumTitle)
        
        let album = NSPopUpButton(frame: .zero)
        album.translatesAutoresizingMaskIntoConstraints = false
        album.addItems(withTitles: [.key("Stop"), .key("Loop"), .key("Next")])
        album.target = self
        album.action = #selector(self.album)
        addSubview(album)
        
        let albumSeparator = Separator()
        addSubview(albumSeparator)
        
        random.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        random.leftAnchor.constraint(equalTo: centerXAnchor, constant: 30).isActive = true
        
        randomTitle.rightAnchor.constraint(equalTo: random.leftAnchor, constant: -20).isActive = true
        randomTitle.centerYAnchor.constraint(equalTo: random.centerYAnchor).isActive = true
        
        randomSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        randomSeparator.topAnchor.constraint(equalTo: random.bottomAnchor, constant: 30).isActive = true
        randomSeparator.leftAnchor.constraint(equalTo: centerXAnchor, constant: -170).isActive = true
        randomSeparator.rightAnchor.constraint(equalTo: centerXAnchor, constant: 170).isActive = true
        
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
        
        
        /*
        
        playback.player.config.sink {
            random.selectItem(at: .init($0.random.rawValue))
        }.store(in: &subs)*/
    }
    
    @objc private func random(_ button: NSPopUpButton) {
        playback.player.config.value.random = Random(rawValue: .init(button.indexOfSelectedItem))!
    }
    
    @objc private func track(_ button: NSPopUpButton) {
        playback.player.config.value.trackEnds = Heuristic(rawValue: .init(button.indexOfSelectedItem))!
    }
    
    @objc private func album(_ button: NSPopUpButton) {
        playback.player.config.value.albumEnds = Heuristic(rawValue: .init(button.indexOfSelectedItem))!
    }
}
