import KoeKit

func audioLevelTests() {
    T.eq(normalizedPower(0), 1.0, "0 dB -> 1")
    T.eq(normalizedPower(-50), 0.0, "floor -> 0")
    T.eq(normalizedPower(-160), 0.0, "below floor -> 0")
    T.eq(normalizedPower(10), 1.0, "above 0 dB clamps to 1")
    let mid = normalizedPower(-25)
    T.isTrue(abs(mid - 0.5) < 0.001, "midpoint -> ~0.5 (got \(mid))")
}
