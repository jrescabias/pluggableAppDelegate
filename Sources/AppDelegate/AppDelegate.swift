import UIKit

@main
class AppDelegate: PluggableApplicationDelegate {
    override var services: [ApplicationService] {
        return [
            DummyService()
        ]
    }
}
