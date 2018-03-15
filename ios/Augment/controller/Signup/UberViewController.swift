//
//  UberViewController.swift
//  Augment
//
//  Created by Sky Xu on 10/14/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit

class UberViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  @IBAction func connectUberAccount(_ sender: Any) {
    let enableCameraVC = EnableCameraViewController.instantiate(fromAppStoryboard: .SignUp)
    self.present(enableCameraVC, animated: true, completion: nil)
  }

  @IBAction func cancelConnectUberAccount(_ sender: Any) {
    self.performSegueToReturnBack()
  }
}
