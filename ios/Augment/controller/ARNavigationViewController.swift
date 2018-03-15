import UIKit
import ARCL
import ARKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

class ARNavigationViewController: UIViewController {
  let sceneLocationView = SceneLocationView()

  let mapView = MKMapView()
  var userAnnotation: MKPointAnnotation?
  var locationEstimateAnnotation: MKPointAnnotation?

  var updateUserLocationTimer: Timer?
  var updateDriverInfoTimer: Timer?

  var centerMapOnUserLocation: Bool = true

  var adjustNorthByTappingSidesOfScreen = false

  var isAnimatingDriverPin: Bool = false

  fileprivate var coordinatesInPress = [CLLocationCoordinate2D]()

  var waypoints = [CLLocationCoordinate2D]()
  var location = [String]()
  var elevationData = [Double]()

  var waypointDispatchGroup = DispatchGroup()

  var driverPin: PinView?

  var currentWaypointIndex: Int = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneLocationView.showAxesNode = true
    sceneLocationView.locationDelegate = self

    view.addSubview(sceneLocationView)

    updateUserLocationTimer = Timer.scheduledTimer(
      timeInterval: 0.5,
      target: self,
      selector: #selector(ARNavigationViewController.updateUserLocation),
      userInfo: nil,
      repeats: true
    )
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    sceneLocationView.run()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    sceneLocationView.pause()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    sceneLocationView.frame = CGRect(
      x: 0,
      y: 0,
      width: self.view.frame.size.width,
      height: self.view.frame.size.height
    )

    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.alpha = 0.8

    mapView.frame = CGRect(
      x: 0,
      y: self.view.frame.size.height / 2,
      width: self.view.frame.size.width,
      height: self.view.frame.size.height / 2)

    view.addSubview(mapView)

    let button = UIButton(frame: CGRect(x: sceneLocationView.frame.width / 2 - 50, y: 75, width: 100, height: 50))
    button.layer.cornerRadius = 10
    button.backgroundColor = .green
    button.setTitle("Generate Path", for: .normal)
    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

    sceneLocationView.addSubview(button)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    if let touch = touches.first {
      if touch.view != nil {
        if (mapView == touch.view! ||
          mapView.recursiveSubviews().contains(touch.view!)) {
          centerMapOnUserLocation = false
        }
      }
    }
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @objc func buttonAction(sender: UIButton!) {
    let originCoord = CLLocationCoordinate2D(latitude: 37.791948, longitude: -122.408364) // driver
    let destinationCoord = CLLocationCoordinate2D(latitude: 37.773688, longitude: -122.417697)

    let driverLocation = CLLocation(coordinate: originCoord, altitude: 25)
    let driverAnnotationNode = LocationAnnotationNode(location: driverLocation, image: #imageLiteral(resourceName: "lyftpin_hotpink"), id: "driver")

    driverAnnotationNode.scaleRelativeToDistance = true

    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: driverAnnotationNode)

    getAPI(origin: originCoord, destination: destinationCoord)

    driverPin = createUserPin(name: "Driver: Bob", eta: 5, image: #imageLiteral(resourceName: "driver_Willie"))
    sceneLocationView.addSubview(driverPin!)

    if updateDriverInfoTimer == nil {
      updateDriverInfoTimer = Timer.scheduledTimer(
        timeInterval: 1,
        target: self,
        selector: #selector(ARNavigationViewController.updateDriverInfo),
        userInfo: nil,
        repeats: true
      )
    }

    sender.isEnabled = false
  }

  func drawNavigationLine(waypoints: [CLLocationCoordinate2D]) {
    self.waypoints = waypoints

    let polyline = MKPolyline(coordinates: waypoints, count: waypoints.count)
    mapView.add(polyline)
    sceneLocationView.addPolyline(polyline)
  }

  @objc func updateUserLocation() {
    if let currentLocation = sceneLocationView.currentLocation() {
      DispatchQueue.main.async {
        if self.userAnnotation == nil {
          self.userAnnotation = MKPointAnnotation()
          self.mapView.addAnnotation(self.userAnnotation!)
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
          self.userAnnotation?.coordinate = currentLocation.coordinate
        }, completion: nil)

        if self.centerMapOnUserLocation {
          UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
          }, completion: {
            _ in
            self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
          })
        }
      }
    }
  }
}

//MARK: Helper functions
extension ARNavigationViewController {
  func createUserPin(name: String, eta: Int, image: UIImage) -> PinView {
    let frame = CGRect(x: self.sceneLocationView.frame.width / 2 - 125, y: 50, width: 250, height: 50)

    let pickupPin = PinView(frame: frame)

    pickupPin.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);

    pickupPin.setupInformation(name: name, eta: 5, image: image)

    return pickupPin
  }

  @objc func updateDriverInfo() {
    DispatchQueue.main.async {
      if let pin = self.driverPin {
        pin.updateETA(by: -1)
        //
        //                if (!self.isAnimatingDriverPin) {
        //                    self.isAnimatingDriverPin = true
        //                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
        //
        //                    }, completion: { (finished: Bool) in
        //                        self.isAnimatingDriverPin = !finished
        //                    })
        //                }
        //
      } else {
        return
      }

    }
  }
}

//MARK: SceneLocationViewDelegate
extension ARNavigationViewController: SceneLocationViewDelegate {

  func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
  }

  func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
  }

  func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {

  }

  func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
  }

  func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
    guard locationNode is LocationAnnotationNode, !waypoints.isEmpty else { return }
    print("DRIVER NODE")

    if (!isAnimatingDriverPin && currentWaypointIndex < waypoints.count) {
      let altitude = sceneLocationView.currentLocation()?.altitude ?? 0

      self.isAnimatingDriverPin = true

      let waypointLocationNode = LocationNode(location: CLLocation(coordinate: self.waypoints[currentWaypointIndex], altitude: altitude))

      sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: waypointLocationNode)

      locationNode.continuallyUpdatePositionAndScale = false

      let move = SCNAction.move(to: waypointLocationNode.position, duration: 5)
      move.timingMode = .linear;

      locationNode.runAction(move) {
        locationNode.continuallyUpdatePositionAndScale = true
        locationNode.location = CLLocation(coordinate: self.waypoints[self.currentWaypointIndex], altitude: altitude)
        self.isAnimatingDriverPin = false
        self.currentWaypointIndex += 1
      }

      //            UIView.animate(withDuration: 10, delay: 0, options:  UIViewAnimationOptions.curveEaseInOut, animations: {
      //                print("ANIMATE")
      //                locationNode.position = waypointLocationNode.position
      //
      //            }, completion: { (finished: Bool) in
      //                self.isAnimatingDriverPin = !finished
      //            })
    }
  }
}

//MARK: MKMapViewDelegate
extension ARNavigationViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }

    if let pointAnnotation = annotation as? MKPointAnnotation {
      let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)

      if pointAnnotation == self.userAnnotation {
        marker.displayPriority = .required
        marker.glyphImage = UIImage(named: "user")
      } else {
        marker.displayPriority = .required
        marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
        marker.glyphImage = UIImage(named: "compass")
      }

      return marker
    }

    return nil
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(polyline: polyline)
      renderer.lineWidth = 10
      renderer.strokeColor = .blue
      renderer.fillColor = .blue
      return renderer
    } else {
      return MKOverlayRenderer(overlay: overlay)
    }
  }
}

//MARK: API
extension ARNavigationViewController {
  func getAPI(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
    let origin = "\(origin.latitude), \(origin.longitude)"
    let destination = "\(destination.latitude), \(destination.longitude)"

    Alamofire.request("https://maps.googleapis.com/maps/api/directions/json", method:.get, parameters:["origin":origin,"destination":destination,"key":"AIzaSyD5PymUhZ6yYARnmzAdk7omFRuCKzV3kSE"])
      .responseJSON { response in
        //                print("got a callback")

        if let jsonValue = response.result.value {
          //                    print("got a response")

          let json = JSON(jsonValue)
          let total = json["routes"][0]["legs"][0]["steps"]
          let num = total.count
          //                    print("got \(num) data points")

          for i in 0..<num {
            let data = total[i]["end_location"]
            //                        print(data)
            guard let lat = data["lat"].double else {return}
            guard let lng = data["lng"].double else {return}
            self.location.append("\(lat),\(lng)")
            //                        print(self.location)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            self.waypoints.append(coord)
          }

          //                    print("calling the completion funtcion")
          self.completionFunction()
        }
      }.resume()
  }

  func getElevation() {
    for i in 0..<(self.location).count {
      waypointDispatchGroup.enter()
      let itemLocation = self.location[i]
      //            print(itemLocation)
      Alamofire.request("https://maps.googleapis.com/maps/api/elevation/json", method:.get, parameters: ["locations":itemLocation, "key":"AIzaSyDxyFhJs9xKf0nT4wFrmfoCecHDLtjAjLU"])
        .responseJSON { response in
          //                    print("got a callback")
          if let jsonValue = response.result.value {
            //                        print("got a response")
            let json = JSON(jsonValue)
            let elevation = json["results"][0]["elevation"]
            let item = elevation.double
            self.elevationData.append(item!)
            self.waypointDispatchGroup.leave()
          }
      }
    }

    waypointDispatchGroup.notify(queue: .main) {
      //            print("Finished all requests.")
      //            print(self.elevationData)
    }
  }

  func completionFunction() -> Void {
    //        print(waypoints)
    //        print("~~~~~~~~~~~~~~~~~~~~\(waypoints.count)")
    //        print(location)
    //
    drawNavigationLine(waypoints: waypoints)

    getElevation()
  }
}

extension DispatchQueue {
  func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
    self.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
  }
}

extension UIView {
  func recursiveSubviews() -> [UIView] {
    var recursiveSubviews = self.subviews

    for subview in subviews {
      recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
    }

    return recursiveSubviews
  }
}
