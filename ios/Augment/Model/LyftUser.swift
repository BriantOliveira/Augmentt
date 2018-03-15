import RealmSwift
import Foundation

// Realm database
class LyftUser: Object {
  @objc dynamic var slack_id = ""
  @objc dynamic var slack_access_token = ""
  @objc dynamic var user_first_name = ""
  @objc dynamic var user_last_name = ""
  @objc dynamic var user_email = ""

  var name: String {
    return "\(user_first_name) \(user_last_name)"
  }

  func save() {
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(self)
      }
    } catch let error as NSError {
      fatalError(error.localizedDescription)
    }
  }
}
