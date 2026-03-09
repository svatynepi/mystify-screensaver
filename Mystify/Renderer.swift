import AppKit

// MARK: - Core Graphics Renderer

/// Encapsulates all drawing logic for the Mystify screensaver using Core Graphics.
///
/// All methods are static — there is no state to maintain between frames.
enum Renderer {

    // MARK: - Frame Drawing

    /// Clears the context to black and draws all wire trails from the simulation.
    static func draw(simulation: Simulation, in bounds: CGRect, context ctx: CGContext) {
        // Fill background black.
        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        ctx.fill(bounds)

        guard bounds.width > 0, bounds.height > 0 else { return }

        ctx.setLineWidth(1.0)

        for wire in simulation.wires {
            draw(wire: wire, in: ctx)
        }
    }

    // MARK: - Wire Drawing

    private static func draw(wire: Wire, in ctx: CGContext) {
        let count = wire.snapshots.count
        guard count > 0 else { return }

        for (index, snapshot) in wire.snapshots.enumerated() {
            guard snapshot.vertices.count >= 2 else { continue }

            let alpha: CGFloat = Configuration.fadeTrails
                ? CGFloat(index + 1) / CGFloat(count)
                : 1.0

            let rgb = snapshot.color.usingColorSpace(.deviceRGB) ?? snapshot.color
            var r: CGFloat = 1, g: CGFloat = 1, b: CGFloat = 1, a: CGFloat = 1
            rgb.getRed(&r, green: &g, blue: &b, alpha: &a)

            ctx.setStrokeColor(CGColor(red: r, green: g, blue: b, alpha: a * alpha))

            // Close the polygon: draw a line from each vertex to the next,
            // wrapping around to the first vertex.
            for i in snapshot.vertices.indices {
                let start = snapshot.vertices[i]
                let end   = snapshot.vertices[(i + 1) % snapshot.vertices.count]
                ctx.move(to: start)
                ctx.addLine(to: end)
            }
            ctx.strokePath()
        }
    }
}
