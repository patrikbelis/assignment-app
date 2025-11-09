import Foundation
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [Screen] = []

    func push(_ route: Screen) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
