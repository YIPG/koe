import SwiftUI
import KeyboardShortcuts

@MainActor
final class PreferencesViewModel: ObservableObject {
    private let prefs: Preferences
    @Published var endpoint: String { didSet { prefs.endpoint = endpoint } }
    @Published var deployment: String { didSet { prefs.deployment = deployment } }
    @Published var apiVersion: String { didSet { prefs.apiVersion = apiVersion } }
    @Published var apiKey: String { didSet { prefs.apiKey = apiKey } }
    @Published var language: String { didSet { prefs.language = language } }

    init(_ prefs: Preferences) {
        self.prefs = prefs
        endpoint = prefs.endpoint
        deployment = prefs.deployment
        apiVersion = prefs.apiVersion
        apiKey = prefs.apiKey ?? ""
        language = prefs.language
    }
}

struct PreferencesView: View {
    @ObservedObject var model: PreferencesViewModel

    var body: some View {
        Form {
            Section("Azure OpenAI") {
                TextField("Endpoint", text: $model.endpoint,
                          prompt: Text("https://<resource>.openai.azure.com"))
                TextField("Deployment", text: $model.deployment)
                TextField("API Version", text: $model.apiVersion)
                SecureField("API Key", text: $model.apiKey)
            }
            Section("Dictation") {
                Picker("Language", selection: $model.language) {
                    Text("Japanese").tag("ja")
                    Text("English").tag("en")
                    Text("Auto").tag("auto")
                }
                KeyboardShortcuts.Recorder("Hotkey", name: .toggleDictation)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
    }
}
