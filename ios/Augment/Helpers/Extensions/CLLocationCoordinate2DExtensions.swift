import CoreLocation

extension CLLocationCoordinate2D: Hashable {

  public var hashValue: Int {
    return latitude.hashValue ^ longitude.hashValue &* 16777619
  }

  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
