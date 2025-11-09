import SwiftUI

struct BlueWhiteBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(red: 242/255, green: 243/255, blue: 247/255)
                    .ignoresSafeArea()

                Color(red: 0/255, green: 26/255, blue: 172/255)
                    .frame(height: geo.size.height / 3)
                    .ignoresSafeArea(edges: .top)
            }
        }
    }
}
