import SwiftUI
import Player

struct Music: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: min(geometry.size.width, geometry.size.height) * 0.1) {
                    Spacer().frame(width: min(geometry.size.width, geometry.size.height) * 0.2)
                    ForEach(Album.allCases, id: \.self) {
                        Image($0.cover)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (min(geometry.size.width, geometry.size.height) * 0.6) - 2,
                                   height: (min(geometry.size.width, geometry.size.height) * 0.6) - 2)
                            .cornerRadius(((min(geometry.size.width, geometry.size.height) * 0.6) - 2) / 2)
                            .padding(2)
                            .background(Color.secondary)
                            .cornerRadius(min(geometry.size.width, geometry.size.height) * 0.3)
                    }
                    Spacer().frame(width: min(geometry.size.width, geometry.size.height) * 0.2)
                }
            }
        }
    }
}
