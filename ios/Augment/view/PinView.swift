import UIKit

class PinView: UIView {
  @IBOutlet var contentView: UIView!

  @IBOutlet weak var pinBackground: UIView!
  @IBOutlet weak var pinImage: UIImageView!

  @IBOutlet weak var pinNameLabel: UILabel!
  @IBOutlet weak var pinETALabel: UILabel!

  private var eta = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    Bundle.main.loadNibNamed("PinView", owner: self, options: nil)

    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

  public func setupInformation(name: String, eta: Int, image: UIImage) {
    pinNameLabel.text = name
    pinETALabel.text = "ETA: \(eta)"
    pinImage.image = image

    pinImage.layer.borderWidth = 1
    pinImage.layer.masksToBounds = false
    pinImage.layer.borderColor = UIColor.black.cgColor
    pinImage.layer.cornerRadius = pinImage.frame.height / 2
    pinImage.clipsToBounds = true

    pinBackground.layer.cornerRadius = 8
  }

  public func updateETA(by amount: Int) {
    eta += amount
    pinETALabel.text = "ETA: \(eta)"
  }

  public func setETA(to amount: Int) {
    eta = amount
  }
}
