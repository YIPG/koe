import Foundation

@main
struct TestMain {
    @MainActor
    static func main() async {
        scaffoldTests()
        keychainStoreTests()
        T.summary()
    }
}
