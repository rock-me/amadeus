import SwiftUI
import Player

struct Music: View {
    @EnvironmentObject var state: Session
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
                        .frame(maxWidth: geometry.size.width * 0.6)
                        .padding()
                    if self.state.purchases.contains(self.album.purchase) {
                        ForEach(self.album.tracks, id: \.self) {
                            Item(track: $0)
                        }
                    } else {
                        Purchase()
                    }
                }
            }.navigationBarTitle(.init(self.album.title))
        }
    }
}

private struct Cover: View {
    @EnvironmentObject var session: Session
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
    @EnvironmentObject var session: Session
    let track: Track
    
    var body: some View {
        NavigationLink(destination: Controls(session: session, track: track)) {
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
        }.accentColor(session.track == track ? .blue : .accentColor)
    }
}

private struct Purchase: View {
    var body: some View {
        VStack {
            Text(.init("In.app"))
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding()
            Text(.init("Check.store"))
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}
