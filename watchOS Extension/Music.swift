import SwiftUI
import Player

struct Music: View {
    let album: Album
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    Cover(album: self.album, size: min(geometry.size.width, geometry.size.height) * 0.6)
                    Text(.init(self.album.subtitle))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                    ForEach(self.album.tracks, id: \.self) {
                        Item(track: $0)
                    }
                }
            }.navigationBarTitle(.init(self.album.title))
        }
    }
}

private struct Cover: View {
    let album: Album
    let size: CGFloat
    
    var body: some View {
        Image(album.cover)
            .resizable()
            .scaledToFill()
            .frame(width: size - 2,
                   height: size - 2)
            .cornerRadius((size - 2) / 2)
            .padding(2)
            .background(Color.blue)
            .cornerRadius(size / 2)
    }
}

private struct Item: View {
    let track: Track
    
    var body: some View {
        Button(action: {
            
        }) {
            VStack {
                HStack {
                    Text(.init(track.title))
                        .font(.footnote)
                    Spacer()
                }
                HStack {
                    Text(.init(track.composer.name))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}
