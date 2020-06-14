import SwiftUI
import Player

struct Controls: View {
    @ObservedObject var session: Session
    let track: Track
    @State private var error = false
    
    var body: some View {
        VStack {
            HStack {
                Text(.init(track.title))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(5)
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                Text(.init(track.composer.name))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(5)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            }
            if session.track == track && session.playing {
                Button(action: {
                    self.error = !self.session.pause()
                }) {
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }.accentColor(.clear)
                    .padding()
            } else {
                Button(action: {
                    self.error = !self.session.change(track: self.track)
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }.accentColor(.clear)
                    .padding()
            }
        }.sheet(isPresented: $error) {
            Text(.init("Failed.sent"))
        }.navigationBarTitle(.init(track.album.title))
    }
}
