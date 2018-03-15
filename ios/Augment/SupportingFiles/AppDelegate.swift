import UIKit
import OAuthSwift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func applicationHandle(url: URL) {
    if (url.host == "oauth-callback") {
      OAuthSwift.handle(url: url)
    } else {
      OAuthSwift.handle(url: url)
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    self.window = UIWindow(frame: UIScreen.main.bounds)

    self.window?.rootViewController = getViewControllerToLoad()

    self.window?.makeKeyAndVisible()

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    applicationHandle(url: url)
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
  }
}

// MARK: Helper funcs
private extension AppDelegate {

  func getViewControllerToLoad() -> UIViewController {

    if doesUserAccountExist() {
      return ARNavigationViewController.instantiate(fromAppStoryboard: .Main)
    }

    return AppStoryboard.SignUp.initialViewController()!
  }

  func doesUserAccountExist() -> Bool {
    do {
      let realm = try Realm()

      if realm.objects(LyftUser.self).first != nil {
        return true
      }
      // TODO: Implement uber side
//      if let uberAcc = realm.objects(UberUser.self).first {
//        return True
//      }

      return false
    } catch let error as NSError {
      fatalError(error.localizedDescription)
    }
  }
}
