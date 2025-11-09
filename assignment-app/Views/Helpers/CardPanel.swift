import SwiftUI

struct CardPanel<Content: View>: View {
    let height: CGFloat
    let content: () -> Content

    init(height: CGFloat = 450, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.content = content
    }

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 8) {
                content()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}
