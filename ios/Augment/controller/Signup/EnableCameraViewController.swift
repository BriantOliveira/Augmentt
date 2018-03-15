import UIKit
import AVFoundation
import UserNotifications

class EnableCameraViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func enableCamera(_ sender: Any) {
    ICanHas.capture { authorized, status in

      guard authorized else {
        let permDeniedVC = PermissionDeniedViewController.instantiate(fromAppStoryboard: .SignUp)
        self.present(permDeniedVC, animated: true)

        return
      }

      let enableLocationVC = EnableLocationViewController.instantiate(fromAppStoryboard: .SignUp)
      self.present(enableLocationVC, animated: true)
    }

  }
}
