import Foundation
import Combine

@MainActor
final class AppDataStore: ObservableObject {
    @Published private(set) var state: CardState = .hidden
    @Published var showActivationError = false
    @Published var showScratchError = false


    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func completeScratch(with code: String) {
        state = .revealed(code: code)
    }

    func activate() async {
        guard case let .revealed(code) = state else { return }
        do {
            let ok = try await checkActivation(for: code)
            if ok {
                self.state = .activated(code: code)
            } else {
                self.showActivationError = true
            }
        } catch {
            self.showActivationError = true
        }
    }

    private func checkActivation(for code: String) async throws -> Bool {
        guard var components = URLComponents(string: "https://api.o2.sk/version") else { return false }
        components.queryItems = [URLQueryItem(name: "code", value: code)]
        guard let endpointUrl = components.url else { return false }
        let (data, _) = try await session.data(from: endpointUrl)
        let resp = try JSONDecoder().decode(ActivationResponse.self, from: data)
        let value = Double(resp.ios) ?? 0.0
        return value > 6.1
    }
}

private struct ActivationResponse: Decodable { let ios: String }
