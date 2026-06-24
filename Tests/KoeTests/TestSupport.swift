import Foundation

/// Minimal assertion harness so the logic suite runs under Command Line Tools
/// (no XCTest). Each test is a plain function that calls into `T`.
enum T {
    static var passed = 0
    static var failed = 0

    static func check(_ cond: Bool, _ msg: @autoclosure () -> String,
                      file: StaticString = #file, line: UInt = #line) {
        if cond {
            passed += 1
        } else {
            failed += 1
            FileHandle.standardError.write(Data("FAIL [\(file):\(line)]: \(msg())\n".utf8))
        }
    }

    static func eq<V: Equatable>(_ a: V, _ b: V, _ label: String = "",
                                 file: StaticString = #file, line: UInt = #line) {
        check(a == b, "\(label) — expected \(b), got \(a)", file: file, line: line)
    }

    static func notNil<V>(_ a: V?, _ label: String = "",
                          file: StaticString = #file, line: UInt = #line) {
        check(a != nil, "\(label) — expected non-nil", file: file, line: line)
    }

    static func isNil<V>(_ a: V?, _ label: String = "",
                         file: StaticString = #file, line: UInt = #line) {
        check(a == nil, "\(label) — expected nil, got \(String(describing: a))", file: file, line: line)
    }

    static func isTrue(_ c: Bool, _ label: String = "",
                       file: StaticString = #file, line: UInt = #line) {
        check(c, "\(label) — expected true", file: file, line: line)
    }

    static func isFalse(_ c: Bool, _ label: String = "",
                        file: StaticString = #file, line: UInt = #line) {
        check(!c, "\(label) — expected false", file: file, line: line)
    }

    static func contains(_ haystack: String, _ needle: String, _ label: String = "",
                         file: StaticString = #file, line: UInt = #line) {
        check(haystack.contains(needle), "\(label) — expected to contain \"\(needle)\"", file: file, line: line)
    }

    static func summary() -> Never {
        print("\(passed) passed, \(failed) failed")
        exit(failed == 0 ? 0 : 1)
    }
}
