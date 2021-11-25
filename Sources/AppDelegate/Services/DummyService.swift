import UIKit
final class DummyService: NSObject, ApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("✅ Here is a dummyService 🛠")
        return true
    }
}
