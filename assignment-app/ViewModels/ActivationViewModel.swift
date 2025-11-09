import SwiftUI
import Combine

@MainActor
final class ActivationViewModel: ObservableObject {
    @Published var isActivating = false

    private let store: AppDataStore

    init(store: AppDataStore) {
        self.store = store
    }

    func activate() {
        guard case .revealed = store.state else { return }
        isActivating = true

        Task { [weak self] in
            guard let self else { return }
            let store = self.store
            do {
                defer { self.isActivating = false }
                try await Task.detached { try await store.activate() }.value
            } catch {
                self.isActivating = false
            }
        }
    }
}

