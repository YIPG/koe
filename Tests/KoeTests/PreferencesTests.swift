import Foundation
import KoeKit

func preferencesTests() {
    let suite = "com.koe.dictation.tests.prefs"
    UserDefaults().removePersistentDomain(forName: suite)
    let prefs = Preferences(
        defaults: UserDefaults(suiteName: suite)!,
        keychain: KeychainStore(service: "com.koe.dictation.tests.prefs")
    )
    prefs.apiKey = nil  // clean slate

    // defaults
    T.eq(prefs.deployment, "gpt-4o-transcribe", "default deployment")
    T.eq(prefs.apiVersion, "2025-03-01-preview", "default apiVersion")
    T.eq(prefs.language, "ja", "default language")
    T.eq(prefs.endpoint, "", "default endpoint empty")

    // persists values
    prefs.endpoint = "https://x.openai.azure.com"
    prefs.apiKey = "KEY123"
    T.eq(prefs.endpoint, "https://x.openai.azure.com", "endpoint persists")
    T.eq(prefs.apiKey ?? "<nil>", "KEY123", "apiKey persists")

    // isConfigured
    T.isTrue(prefs.isConfigured, "configured when endpoint+key set")

    // clearing api key
    prefs.apiKey = nil
    T.isNil(prefs.apiKey, "apiKey cleared")
    T.isFalse(prefs.isConfigured, "not configured without key")

    // cleanup
    UserDefaults().removePersistentDomain(forName: suite)
}
