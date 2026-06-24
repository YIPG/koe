import Foundation

@main
struct TestMain {
    @MainActor
    static func main() async {
        scaffoldTests()
        keychainStoreTests()
        preferencesTests()
        transcriptionServiceTests()
        await dictationCoordinatorTests()
        T.summary()
    }
}
