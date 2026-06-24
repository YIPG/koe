import KoeKit

func keychainStoreTests() {
    // Unique service so we never touch real koe credentials.
    let store = KeychainStore(service: "com.koe.dictation.tests")
    store.delete("k")

    // set / get round trip
    do { try store.set("secret-value", for: "k") }
    catch { T.check(false, "set threw \(error)") }
    T.eq(store.get("k") ?? "<nil>", "secret-value", "round trip")

    // overwrite
    try? store.set("second", for: "k")
    T.eq(store.get("k") ?? "<nil>", "second", "overwrite")

    // delete
    store.delete("k")
    T.isNil(store.get("k"), "delete removes value")

    // missing key
    T.isNil(store.get("does-not-exist"), "missing key returns nil")
}
