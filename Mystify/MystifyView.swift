import ScreenSaver

// MARK: - MystifyView

/// Main screen saver view that coordinates the simulation and Core Graphics renderer.
///
/// `MystifyView` is the `NSPrincipalClass` referenced by `Info.plist`.
/// It owns the ``Simulation`` value type (updated each frame) and the
/// ``Renderer`` (Core Graphics pipeline).  All heavy lifting is delegated to
/// those two components; this class handles only view lifecycle and
/// frame orchestration.
final class MystifyView: ScreenSaverView {

    // MARK: - Properties

    private var simulation = Simulation(bounds: .zero)

    // MARK: - Initialization

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    // MARK: - ScreenSaverView Overrides

    override var hasConfigureSheet: Bool { false }

    override var configureSheet: NSWindow? { nil }

    override func animateOneFrame() {
        simulation.advance(within: bounds.size)
        setNeedsDisplay(bounds)
    }

    override func draw(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        Renderer.draw(simulation: simulation, in: bounds, context: ctx)
    }

    // MARK: - Setup

    private func setUp() {
        animationTimeInterval = Configuration.frameInterval
        simulation = Simulation(bounds: bounds.size)
    }
}
