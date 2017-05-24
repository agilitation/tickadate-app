import Foundation
import UIKit
@IBDesignable

class XibView: UIView {
  
  @IBInspectable var xibName: String?
  
  override func awakeFromNib() {
    guard let name = self.xibName,
      let xib = Bundle.main.loadNibNamed(name, owner: self),
      let views = xib as? [UIView], views.count > 0 else { return }
    self.addSubview(views[0] )
  }
}
