import AppKit
import Combine

final class Music: NSView {
    private weak var detail: Detail!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let spectrogram = Spectrogram()
        scroll.add(spectrogram)
        
        let coverflow = Coverflow(music: self)
        scroll.add(coverflow)
        
        let detail = Detail()
        scroll.add(detail)
        self.detail = detail
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 30).isActive = true
        
        spectrogram.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        spectrogram.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        spectrogram.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: spectrogram.bottomAnchor, constant: 30).isActive = true
        coverflow.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        coverflow.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        detail.topAnchor.constraint(equalTo: coverflow.bottomAnchor, constant: 30).isActive = true
        detail.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        detail.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
        
        persistance.ui.sink { [weak self] in
            self?.select(album: $0!.album)
        }.store(in: &subs)
    }
    
    func select(album: Album) {
        detail.show(album)
    }
}
