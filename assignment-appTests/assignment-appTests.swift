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

    func hiddenOnInit() async {
        let store = AppDataStore()

        if case .hidden = store.state {
        } else {
            XCTFail("Expected .hidden")
        }
    }

    func revealFunction() async {
        let store = await MainActor.run { AppDataStore() }
        store.completeScratch(with: "CODE-123")
        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected .revealed")
        }
        XCTAssertEqual(code, "ABC")
    }

    func activationFunction() async {
        let json = #"{"ios":"6.24"}"#
        let store = makeStoreReturning(json: json)
        store.completeScratch(with: "CODE-123")

        await store.activate()

        guard case .activated(let code) = store.state else {
            return XCTFail("Expected .activated")
        }
        XCTAssertEqual(code, "CODE-123")
        XCTAssertFalse(store.showActivationError)
    }

    func activationWithFailFunction() async {
        let json = #"{"ios":"6.0"}"#
        let store = makeStoreReturning(json: json)
        store.completeScratch(with: "CODE-123")

        await store.activate()

        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected still .revealed")
        }
        XCTAssertEqual(code, "CODE-LOW")
        XCTAssertTrue(store.showActivationError)
    }

    func activationWithNetworkErrorFunction() async {
        URLProtocolMock.handler = { _ in throw URLError(.timedOut) }
        let store = AppDataStore(session: makeMockedSession())
        store.completeScratch(with: "ERR")

        await store.activate()

        guard case .revealed(let code) = store.state else {
            return XCTFail("Expected still .revealed")
        }
        XCTAssertEqual(code, "ERR")
        XCTAssertTrue(store.showActivationError)
    }}
