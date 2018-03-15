import UIKit
import SafariServices
import Foundation
import RealmSwift

class LyftViewController: UIViewController {
  let api = API()

  override func viewDidLoad() {
    super.viewDidLoad()

    print("FAJSLKDJFKLASJDFKASJDLFKASDLKFJAKLSJFKLSJDKLFJASKLD\n\(Realm.Configuration.defaultConfiguration.fileURL!)")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func connectLyftAccount(_ sender: Any) {
    api.authenticateWithView(viewController: self) {
      let enableCameraVC = EnableCameraViewController.instantiate(fromAppStoryboard: .SignUp)
      self.present(enableCameraVC, animated: true, completion: nil)
    }
  }

  @IBAction func skipConnectLyftAccount(_ sender: Any) {
    self.performSegueToReturnBack()
  }
}
