


import UIKit
import Parse
import FBSDKLoginKit
import ParseFacebookUtilsV4
var firstStartup = Bool()



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Init Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_KEY
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        // Push Notifications
        let notifTypes:UIUserNotificationType  = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: notifTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        
        // Bool to detect the first app startup
        firstStartup = true
        
        //Set Colors

        UINavigationBar.appearance().barTintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.6)
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 73/255.0, green: 205/255.0, blue: 226/255.0, alpha: 0.95)]
        UINavigationBar.appearance().titleTextAttributes = titleDict as? [String : Any]
        
        // Set Status Bar Light
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)

        PFPurchase.addObserver(forProduct: "com.schuaman.yogastudioPremium", block: {(transaction:SKPaymentTransaction!)->Void in
            //sending notification
            
        })
        return true
    }
    
    
    // Delegates for Push Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground(block: { (succ, error) in
            if error == nil {
                print("Device registered")
            } else {
                print("\(error!.localizedDescription)")
            }
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        PFPush.handle(userInfo)
        if application.applicationState == .inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(inBackground: userInfo, block: nil)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
 
}

