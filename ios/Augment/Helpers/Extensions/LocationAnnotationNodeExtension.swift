import Foundation
import ARCL
import ARKit
import CoreLocation

protocol PropertyStoring {

  associatedtype T

  func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T?) -> T?
}

extension PropertyStoring {
  func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T?) -> T? {
    guard let value = objc_getAssociatedObject(self, key) as? T else {
      return defaultValue
    }
    return value
  }
}

extension LocationAnnotationNode: PropertyStoring {

  typealias T = String

  private struct CustomProperties {
    static var id: String?
  }

  var id: String? {
    get {
      return getAssociatedObject(&CustomProperties.id, defaultValue: nil)
    }
    set {
      return objc_setAssociatedObject(self, &CustomProperties.id, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }

  public convenience init(location: CLLocation?, image: UIImage, id: String) {
    self.init(location: location, image: image)
    self.id = id
  }

  private func updateID(to id: String) {
    self.id = id
  }
}
