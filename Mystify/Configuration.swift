import Foundation

// MARK: - Screensaver Configuration

/// Centralizes every tunable parameter for the Mystify screensaver.
/// All values are compile-time constants grouped under a caseless enum
/// so they cannot be accidentally instantiated.
enum Configuration {

    /// Number of independent wire polygons drawn simultaneously.
    static let wireCount = 2

    /// Number of corner vertices that define each wire polygon.
    static let verticesPerWire = 4

    /// Maximum number of trailing snapshots retained per wire.
    static let maxTrailLength = 5

    /// Minimum corner movement speed in points per frame.
    static let minSpeed: CGFloat = 2.0

    /// Additional random range added to `minSpeed` for each velocity component.
    static let speedRange: CGFloat = 15.0

    /// Base rate of hue cycling per frame (before applying `hueChangeDivisor`).
    static let hueChangeBase = 0.5

    /// Random variance added to `hueChangeBase` when initializing each wire.
    static let hueChangeVariance = 0.2

    /// Divisor that slows hue change to a visually pleasant rate.
    static let hueChangeDivisor = 1000.0

    /// Target interval between animation frames, in seconds.
    static let frameInterval: TimeInterval = 0.035

    /// When `true`, older trail snapshots are rendered with progressively lower opacity.
    static let fadeTrails = false
}
