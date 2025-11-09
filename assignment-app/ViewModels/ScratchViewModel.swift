import SwiftUI
import Combine

@MainActor
final class ScratchViewModel: ObservableObject {
    @Published var isScratching = false

    private let store: AppDataStore
    private var task: Task<Void, Never>?

    init(store: AppDataStore) {
        self.store = store
    }

    func scratch(onSuccess: @escaping () -> Void) {
        guard !isScratching else { return }
        isScratching = true

        task = Task {
            do {
                try await Task.sleep(for: .seconds(2))
                try Task.checkCancellation()

                let code = UUID().uuidString
                store.completeScratch(with: code)

                isScratching = false
                onSuccess()
            } catch is CancellationError {
                isScratching = false
            } catch {
                isScratching = false
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        isScratching = false
    }
}
