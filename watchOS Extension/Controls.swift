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
                    .padding()
                Spacer()
            }
            HStack {
                Text(.init(track.composer.name))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
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
