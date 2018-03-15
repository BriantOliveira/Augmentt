import UIKit

class EnableLocationViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func enableLocation(_ sender: Any) {
    ICanHas.location { authorized, status in

      guard authorized else {
        let permDeniedVC = PermissionDeniedViewController.instantiate(fromAppStoryboard: .SignUp)
        self.present(permDeniedVC, animated: true)

        return
      }

      let arNavigationViewController = ARNavigationViewController.instantiate(fromAppStoryboard: .Main)
      self.present(arNavigationViewController, animated: true)
    }
  }
}
