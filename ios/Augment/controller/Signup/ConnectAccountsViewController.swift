import UIKit
import RealmSwift

final class ConnectAccountsViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func connectLyftAccount(_ sender: Any) {
    let lyftViewController = LyftViewController.instantiate(fromAppStoryboard: .SignUp)
    self.present(lyftViewController, animated: true, completion: nil)
  }

  @IBAction func connectUberAccount(_ sender: Any) {
    let uberViewController = UberViewController.instantiate(fromAppStoryboard: .SignUp)
    self.present(uberViewController, animated: true, completion: nil)
  }
}
