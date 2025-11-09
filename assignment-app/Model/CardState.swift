import Foundation

enum CardState: Equatable {
    case hidden
    case revealed(code: String)
    case activated(code: String)
}
