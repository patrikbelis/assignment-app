import XCTest
import Combine
@testable import assignment_app

@MainActor
final class assignment_appTests: XCTestCase {
    private func makeStoreReturning(json: String, status: Int = 200) -> AppDataStore {
        URLProtocolMock.handler = { request in
            XCTAssertTrue(request.url?.query?.contains("code=") == true)
            let resp = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (resp, Data(json.utf8))
        }
        return AppDataStore(session: makeMockedSession())
    }

    override func tearDown() {
        URLProtocolMock.handler = nil
        super.tearDown()
    }

    func test_hiddenOnInit() {
        let store = AppDataStore()
        switch store.state {
        case .hidden: break
        default: XCTFail("Expected .hidden")
        }
    }

    func test_revealFunction() {
        let store = AppDataStore()
        store.completeScratch(with: "CODE-123")
        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected .revealed")
        }
        XCTAssertEqual(code, "CODE-123")
    }

    func test_activation_success() async {
        let json = #"{"ios":"6.24"}"#
        let store = makeStoreReturning(json: json)
        store.completeScratch(with: "CODE-123")

        do {
            try await store.activate()
        } catch {
            return XCTFail("Unexpected error: \(error)")
        }

        guard case .activated(let code) = store.state else {
            return XCTFail("Expected .activated")
        }
        XCTAssertEqual(code, "CODE-123")
        XCTAssertFalse(store.showActivationError)
    }

    func test_activation_fails_with_unsupported_version() async {
        let json = #"{"ios":"6.0"}"#
        let store = makeStoreReturning(json: json)
        store.completeScratch(with: "CODE-LOW")

        do {
            try await store.activate()
            return XCTFail("Expected ActivationError.unsupportedVersion, but no error was thrown")
        } catch let error as ActivationError {
            XCTAssertEqual(error, .unsupportedVersion)
        } catch {
            return XCTFail("Unexpected error: \(error)")
        }

        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected still .revealed")
        }
        XCTAssertEqual(code, "CODE-LOW")
        XCTAssertTrue(store.showActivationError)
    }

    func test_activation_fails_with_network_error() async {
        URLProtocolMock.handler = { _ in throw URLError(.timedOut) }
        let store = AppDataStore(session: makeMockedSession())
        store.completeScratch(with: "ERR")

        do {
            try await store.activate()
            return XCTFail("Expected network error, but no error was thrown")
        } catch let error as ActivationError {
            XCTAssertEqual(error, .network(URLError(.timedOut)))
        } catch {
            return XCTFail("Unexpected error: \(error)")
        }

        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected still .revealed")
        }
        XCTAssertEqual(code, "ERR")
        XCTAssertTrue(store.showActivationError)
    }
}
