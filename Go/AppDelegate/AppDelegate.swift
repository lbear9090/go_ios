//
//  AppDelegate.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import AWSS3
import FBSDKCoreKit
import Branch
import Fabric
import Crashlytics
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var window: UIWindow?
    let tabBarDelegate = GoTabBarDelegate()
    
    var shouldHandlePushNavigation: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SHOEnvironment.shared.environment = currentEnvironment
        self.registerForAPIUnauthorizedNotification()
        setupAppearance()

        self.configureAWS()
        GMSServices.provideAPIKey(self.googleMapsAPIKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
        
        self.rootToLaunchAnimationController {
            if let _ = try? CacheManager.getConfigurations(),
                let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable : Any],
                SHOSessionManager.shared.isLoggedIn {
                                
                self.rootToFeedController(completion: {
                    self.shouldHandlePushNavigation = true
                    self.application(application, didReceiveRemoteNotification: remoteNotification)
                    self.shouldHandlePushNavigation = false
                })
            }
            else {
                self.rootToConfigurationController()
            }
            
            self.configureBranchSession(with: launchOptions)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled;
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return branchHandled
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    // MARK: - Helpers
    
    func rootToConfigurationController(completion: (() -> Void)? = nil) {
        self.setControllerAsRoot(controller: ConfigurationViewController(), completion: completion)
    }
    
    func rootToLandingController(completion: (() -> Void)? = nil) {
        let navController = UINavigationController(rootViewController: LandingViewController())
        self.setControllerAsRoot(controller: navController, completion: completion)
    }
    
    func rootToFeedController(completion: (() -> Void)? = nil) {
        self.registerForPushNotifications()
        
        let tabController = UITabBarController.configuredTabBarController()
        tabController.delegate = self.tabBarDelegate
        self.setControllerAsRoot(controller: tabController, completion: completion)
        
        if let sharedEventId = try? CacheManager.getPendingShareEventId() {
            let controller = EventViewController(withId: sharedEventId)
            tabController.currentViewController?.navigationController?.pushViewController(controller, animated: true)
            try? CacheManager.removedPendingShareEventId()
        }
    }
    
    func rootToLaunchAnimationController(completion: (() -> Void)? = nil) {
        let controller = LaunchAnimationViewController()
        controller.finishedAnimationHandler = {
            completion?()
        }
        self.setControllerAsRoot(controller: controller)
    }
    
    func setControllerAsRoot(controller: UIViewController, completion: (() -> Void)? = nil) {
        guard let window = self.window else {
            return
        }
        window.backgroundColor = .white
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { window.rootViewController = controller },
                          completion: {(finished) in completion?()})
    }
    
    func configureAWS() {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1,
                                                               identityPoolId: SHOConfigurations.AWSIdentidyPoolId.value)
        
        let configuration = AWSServiceConfiguration(region: .EUWest1,
                                                    credentialsProvider: credentialProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func configureBranchSession(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        #if RELEASE_BUILD
            // No settings required for Branch for release build
        #else
            Branch.setUseTestBranchKey(true)
        #endif
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            
            if let params = params as? [String: AnyObject],
                let branchLinkClicked = params["+clicked_branch_link"] as? Bool,
                branchLinkClicked == true {
                
                if let eventIDStr = params[Constants.branchEventIDKey] as? String,
                    let eventID = eventIDStr.toNumber()?.int64Value {
                    
                    DispatchQueue.main.async {
                            if SHOSessionManager.shared.isLoggedIn {
                                if let rootController = self.window?.rootViewController as? UITabBarController {
                                    let controller = EventViewController(withId: eventID)
                                    rootController.currentViewController?.navigationController?.pushViewController(controller, animated: true)
                                }
                            } else {
                                do {
                                    try CacheManager.storePendingShareEventId(eventID)
                                } catch let error {
                                    print("Error storing pending share event ID: \(error)")
                                }
                            }
                        }
                    }
                }
            })
    }
    
    // MARK: - Environment

    var currentEnvironment: SHOEnvironment.Environment {
        #if RELEASE_BUILD
            return SHOEnvironment.Environment.production
        #elseif (BETA_BUILD)
            return SHOEnvironment.Environment.beta
        #else
            return SHOEnvironment.Environment.development
        #endif
    }
    
    var googleMapsAPIKey: String {
        switch currentEnvironment {
        case .production:
            return "AIzaSyD-6VOtc0t9WPZP52lbbc4tYQBFYWEl8Do"
        case .beta:
            return "AIzaSyDinZI59WDUlfNa0mVqYRxbrNmnUck7SJs"
        case .development:
            return "AIzaSyDE-koozjcGA7T50FCSi1eoA9oAPrUbQRI"
        }
    }
    
    // MARK: - Unauthorized API Notififcation
    
    private func registerForAPIUnauthorizedNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recievedUnauthorizedAPIResponse(notification:)),
                                               name: NSNotification.Name(rawValue: SHOParser.SHOAPIClientDidReceiveUnauthorizedNotification),
                                               object: nil)
    }
    
    @objc private func recievedUnauthorizedAPIResponse(notification: NSNotification) {
        if SHOSessionManager.shared.isLoggedIn {
            
            SHOAPIClient.shared.logout { object, error, code in
                SHOUtils.logoutUser()
            }
            
            self.rootToLandingController(completion: {
                
                let message = notification.object as? String ?? "ERROR_UNAUTHORIZED_MESSAGE".localized
                
                let alert = UIAlertController(title: "ERROR_ALERT_TITLE".localized,
                                              message: message,
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "ALERT_ACTION_OK".localized,
                                           style: .default)
                
                alert.addAction(action)
                self.window?.rootViewController?.present(alert, animated: true)
            })
        }
    }

}
