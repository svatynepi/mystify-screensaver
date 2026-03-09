import AppKit

// MARK: - Data Models

/// A single corner vertex of a wire polygon, carrying both position and velocity.
struct Corner {
    var position: CGPoint
    var velocity: CGVector
}

/// A frozen snapshot of a wire polygon at one point in time.
struct Snapshot {
    let vertices: [CGPoint]
    let color: NSColor
}

/// A wire polygon that moves around the screen, bounces off edges,
/// and continuously cycles through hue values.
struct Wire {
    var corners: [Corner]
    var snapshots: [Snapshot]
    var hue: Double
    var hueChangeSpeed: Double
}

// MARK: - Simulation

/// Pure-data simulation state for the Mystify screensaver.
///
/// Create an instance with the initial view bounds, then call
/// ``advance(within:)`` once per frame to update all wire positions
/// and record new trail snapshots.
struct Simulation {

    // MARK: Public State

    private(set) var wires: [Wire]

    // MARK: Initialization

    /// Creates a new simulation with randomized wires fitting the given bounds.
    init(bounds: CGSize) {
        wires = (0..<Configuration.wireCount).map { index in
            Wire(
                corners: Self.makeRandomCorners(within: bounds),
                snapshots: [],
                hue: Double(index) / Double(Configuration.wireCount),
                hueChangeSpeed: Configuration.hueChangeBase
                    + Configuration.hueChangeVariance * .random(in: 0..<1)
            )
        }
    }

    // MARK: Advancing

    /// Moves every corner, bounces off edges, advances hue, and records a new
    /// trail snapshot for each wire.
    mutating func advance(within bounds: CGSize) {
        let width = bounds.width
        let height = bounds.height

        for index in wires.indices {
            moveCorners(of: index, width: width, height: height)
            cycleHue(of: index)
            recordSnapshot(for: index)
            trimTrail(for: index)
        }
    }

    // MARK: - Corner Movement

    private mutating func moveCorners(of wireIndex: Int, width: CGFloat, height: CGFloat) {
        for i in wires[wireIndex].corners.indices {
            var corner = wires[wireIndex].corners[i]

            var x = corner.position.x + corner.velocity.dx
            var y = corner.position.y + corner.velocity.dy
            var dx = corner.velocity.dx
            var dy = corner.velocity.dy

            if x < 0 {
                x = 0
                dx = Self.randomPositiveSpeed()
            } else if x > width {
                x = width
                dx = -Self.randomPositiveSpeed()
            }

            if y < 0 {
                y = 0
                dy = Self.randomPositiveSpeed()
            } else if y > height {
                y = height
                dy = -Self.randomPositiveSpeed()
            }

            corner.position = CGPoint(x: x, y: y)
            corner.velocity = CGVector(dx: dx, dy: dy)
            wires[wireIndex].corners[i] = corner
        }
    }

    // MARK: - Hue Cycling

    private mutating func cycleHue(of wireIndex: Int) {
        wires[wireIndex].hue += wires[wireIndex].hueChangeSpeed / Configuration.hueChangeDivisor
    }

    // MARK: - Snapshots

    private mutating func recordSnapshot(for wireIndex: Int) {
        let hue = normalizedHue(wires[wireIndex].hue)
        let color = NSColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)

        let snapshot = Snapshot(
            vertices: wires[wireIndex].corners.map(\.position),
            color: color
        )
        wires[wireIndex].snapshots.append(snapshot)
    }

    private mutating func trimTrail(for wireIndex: Int) {
        let excess = wires[wireIndex].snapshots.count - Configuration.maxTrailLength
        if excess > 0 {
            wires[wireIndex].snapshots.removeFirst(excess)
        }
    }

    // MARK: - Random Helpers

    private static func makeRandomCorners(within bounds: CGSize) -> [Corner] {
        (0..<Configuration.verticesPerWire).map { _ in
            Corner(
                position: CGPoint(
                    x: .random(in: 0...bounds.width),
                    y: .random(in: 0...bounds.height)
                ),
                velocity: CGVector(
                    dx: randomSignedSpeed(),
                    dy: randomSignedSpeed()
                )
            )
        }
    }

    private static func randomPositiveSpeed() -> CGFloat {
        .random(in: Configuration.minSpeed...(Configuration.minSpeed + Configuration.speedRange))
    }

    private static func randomSignedSpeed() -> CGFloat {
        Bool.random() ? randomPositiveSpeed() : -randomPositiveSpeed()
    }

    // MARK: - Color Helpers

    private func normalizedHue(_ value: Double) -> CGFloat {
        var h = value.truncatingRemainder(dividingBy: 1.0)
        if h < 0 { h += 1.0 }
        return CGFloat(h)
    }
}
