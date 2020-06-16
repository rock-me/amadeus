import AppKit
import Player
import Combine

final class Music: NSView {
    private weak var detail: Detail!
    private weak var coverflow: Coverflow!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let scroll = Scroll()
        scroll.horizontalScrollElasticity = .none
        addSubview(scroll)
        
        let coverflow = Coverflow(music: self)
        scroll.add(coverflow)
        self.coverflow = coverflow
        
        let detail = Detail()
        scroll.add(detail)
        self.detail = detail
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 30).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        coverflow.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        detail.topAnchor.constraint(equalTo: coverflow.bottomAnchor, constant: 30).isActive = true
        detail.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        state.player.track.dropFirst().first().sink { [weak self] in
            self?.select(album: $0.album)
        }.store(in: &subs)
    }
    
    func select(album: Album) {
        coverflow.show(album)
        detail.show(album)
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
}
