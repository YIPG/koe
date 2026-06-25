import Foundation

@main
struct TestMain {
    @MainActor
    static func main() async {
        scaffoldTests()
        keychainStoreTests()
        preferencesTests()
        transcriptionServiceTests()
        await preferencesTranscriptionServiceTests()
        await dictationCoordinatorTests()
        T.summary()
    }
}
