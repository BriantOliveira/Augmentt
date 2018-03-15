import UIKit

/// Easily return to previous view
extension UIViewController {
  func performSegueToReturnBack()  {
    if let nav = self.navigationController {
      nav.popViewController(animated: true)
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
}
