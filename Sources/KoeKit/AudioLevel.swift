import Foundation

/// Map AVAudioRecorder `averagePower(forChannel:)` decibels (~ -160…0) to 0…1,
/// treating anything at/below `floor` as silence.
public func normalizedPower(_ decibels: Float, floor: Float = -50) -> Float {
    if decibels >= 0 { return 1 }
    if decibels <= floor { return 0 }
    return (decibels - floor) / (0 - floor)
}
