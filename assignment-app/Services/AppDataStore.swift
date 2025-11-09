import Foundation
import Combine

enum ActivationError: LocalizedError, Equatable {
    case invalidURL
    case invalidState
    case unsupportedVersion
    case invalidResponse
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Neplatná adresa servera."
        case .invalidState:
            return "Kód sa nedá aktivovať v aktuálnom stave karty."
        case .unsupportedVersion:
            return "Aktivácia zlyhala — verzia iOS je nižšia ako 6.1."
        case .invalidResponse:
            return "Server vrátil neplatnú odpoveď."
        case .network(let err):
            return "Chyba siete: \(err.localizedDescription)"
        }
    }

    static func == (lhs: ActivationError, rhs: ActivationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.invalidState, .invalidState),
            (.unsupportedVersion, .unsupportedVersion),
            (.invalidResponse, .invalidResponse):
            return true
        case (.network, .network):
            return true
        default:
            return false
        }
    }
}

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

    func activate() async throws {
        guard case let .revealed(code) = state else {
            throw ActivationError.invalidState
        }

        do {
            let ok = try await checkActivation(for: code)
            if ok {
                state = .activated(code: code)
            } else {
                showActivationError = true
                throw ActivationError.unsupportedVersion
            }
        } catch let error as ActivationError {
            showActivationError = true
            throw error
        } catch {
            showActivationError = true
            throw ActivationError.network(error)
        }
    }

    private func checkActivation(for code: String) async throws -> Bool {
        guard var components = URLComponents(string: "https://api.o2.sk/version") else {
            throw ActivationError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "code", value: code)]
        guard let endpointUrl = components.url else {
            throw ActivationError.invalidURL
        }

        let (data, _) = try await session.data(from: endpointUrl)
        let resp = try JSONDecoder().decode(ActivationResponse.self, from: data)
        guard let value = Double(resp.ios) else {
            throw ActivationError.invalidResponse
        }

        return value > 6.1
    }
}

private struct ActivationResponse: Decodable { let ios: String }
