import UIKit

/// This is only a tagging protocol.
/// It doesn't add more functionalities yet.
public protocol ApplicationService: UIApplicationDelegate {}

open class PluggableApplicationDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    open var services: [ApplicationService] { return [] }
    private lazy var aplicationServices: [ApplicationService] = {
        return self.services
    }()
    @discardableResult
    private func apply<T, S>(_ work: (ApplicationService, @escaping (T) -> Void) -> S?, completionHandler: @escaping ([T]) -> Swift.Void) -> [S] {
        let dispatchGroup = DispatchGroup()
        var results: [T] = []
        var returns: [S] = []
        for service in aplicationServices {
            dispatchGroup.enter()
            let returned = work(service, { result in
                results.append(result)
                dispatchGroup.leave()
            })
            if let returned = returned {
                returns.append(returned)
            } else { // delegate doesn't impliment method
                dispatchGroup.leave()
            }
            if returned == nil {
            }
        }
        dispatchGroup.notify(queue: .main) {
            completionHandler(results)
        }
        return returns
    }
    open func applicationDidFinishLaunching(_ application: UIApplication) {
        aplicationServices.forEach { $0.applicationDidFinishLaunching?(application) }
    }
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }
    open func applicationDidBecomeActive(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationDidBecomeActive?(application)
        }
    }
    open func applicationWillResignActive(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationWillResignActive?(application)
        }
    }
    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Please use application:openURL:options:")
    open func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, handleOpen: url) ?? false {
                result = true
            }
        }
        return result
    }
    @available(iOS, introduced: 4.2, deprecated: 9.0, message: "Please use application:openURL:options:")
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ?? false {
                result = true
            }
        }
        return result
    }
    @available(iOS 9.0, *)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(app, open: url, options: options) ?? false {
                result = true
            }
        }
        return result
    }
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationDidReceiveMemoryWarning?(application)
        }
    }
    open func applicationWillTerminate(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationWillTerminate?(application)
        }
    }
    open func applicationSignificantTimeChange(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationSignificantTimeChange?(application)
        }
    }
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotification UNNotification Settings instead")
    open func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        for service in aplicationServices {
            service.application?(application, didRegister: notificationSettings)
        }
    }
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        for service in aplicationServices {
            service.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        for service in aplicationServices {
            service.application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }
    @available(iOS, introduced: 3.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        for service in aplicationServices {
            service.application?(application, didReceiveRemoteNotification: userInfo)
        }
    }
    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        for service in aplicationServices {
            service.application?(application, didReceive: notification)
        }
    }

    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Swift.Void) {
        apply({ (service, completion) -> Void? in
            service.application?(application,
                                 handleActionWithIdentifier: identifier,
                                 for: notification,
                                 completionHandler: { completion(completionHandler) })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
        apply({ (service, handler) -> Void? in
            service.application?(application,
                                 handleActionWithIdentifier: identifier,
                                 forRemoteNotification: userInfo,
                                 withResponseInfo: responseInfo,
                                 completionHandler: { handler(completionHandler) })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
        apply({ (service, handler) -> Void? in
            service.application?(application,
                                 handleActionWithIdentifier: identifier,
                                 forRemoteNotification: userInfo,
                                 completionHandler: { handler(completionHandler) })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
        apply({ (service, handler) -> Void? in
            service.application?(application,
                                 handleActionWithIdentifier: identifier,
                                 for: notification,
                                 withResponseInfo: responseInfo,
                                 completionHandler: { handler(completionHandler) })
        }, completionHandler: { _ in
            completionHandler()
        })
    }

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        apply({ (service, completionHandler) -> Void? in
            service.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }, completionHandler: { results in
            let result = results.min(by: { $0.rawValue < $1.rawValue }) ?? .noData
            completionHandler(result)
        })
    }
    @available(iOS 9.0, *)
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {
        apply({ (service, completionHandler) -> Void? in
            service.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler)
        }, completionHandler: { results in
            // if any service handled the shortcut, return true
            let result = results.reduce(false, { $0 || $1 })
            completionHandler(result)
        })
    }
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        apply({ (service, handler) -> Void? in
            service.application?(application, handleEventsForBackgroundURLSession: identifier, completionHandler: {
                handler(completionHandler)
            })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    @available(iOS 8.2, *)
    open func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Swift.Void) {
        for service in aplicationServices {
            service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
        }
        apply({ (service, reply) -> Void? in
            service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
        }, completionHandler: { results in
            let result = results.reduce([:], { initial, next in
                var initial = initial
                for (key, value) in next ?? [:] {
                    initial[key] = value
                }
                return initial
            })
            reply(result)
        })
    }
    @available(iOS 9.0, *)
    open func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationShouldRequestHealthAuthorization?(application)
        }
    }
    open func applicationDidEnterBackground(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationDidEnterBackground?(application)
        }
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationWillEnterForeground?(application)
        }
    }

    open func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationProtectedDataWillBecomeUnavailable?(application)
        }
    }

    open func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        for service in aplicationServices {
            service.applicationProtectedDataDidBecomeAvailable?(application)
        }
    }

    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, shouldAllowExtensionPointIdentifier: extensionPointIdentifier) ?? true {
                result = true
            }
        }
        return result
    }
    open func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        for service in aplicationServices {
            if let viewController = service.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
                return viewController
            }
        }
        return nil
    }

    @available(iOS 13.2, *)
    open func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, shouldSaveSecureApplicationState: coder) ?? false {
                result = true
            }
        }
        return result
    }

    open func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, shouldRestoreApplicationState: coder) ?? false {
                result = true
            }
        }
        return result
    }

    open func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        for service in aplicationServices {
            service.application?(application, willEncodeRestorableStateWith: coder)
        }
    }

    open func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        for service in aplicationServices {
            service.application?(application, didDecodeRestorableStateWith: coder)
        }
    }
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        var result = false
        for service in aplicationServices {
            if service.application?(application, willContinueUserActivityWithType: userActivityType) ?? false {
                result = true
            }
        }
        return result
    }
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let returns = apply({ (service, restorationHandler) -> Bool? in
            service.application?(application, continue: userActivity, restorationHandler: restorationHandler)
        }, completionHandler: { results in
            let result = results.reduce([], { $0 + ($1 ?? []) })
            restorationHandler(result)
        })
        return returns.reduce(false, { $0 || $1 })
    }
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        for service in aplicationServices {
            service.application?(application, didFailToContinueUserActivityWithType: userActivityType, error: error)
        }
    }
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        for service in aplicationServices {
            service.application?(application, didUpdate: userActivity)
        }
    }
}
