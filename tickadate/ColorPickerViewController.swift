//
//  ColorPickerViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 16/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import Eureka

private let reuseIdentifier = "cell"

final class ColorPickerCell: Cell<ColorPaletteItem>, CellType {
  
  var circle:CircleView!
  
  // IBOutlets or whatever you need for your cell
  public override func setup() {
    
    height = { BaseRow.estimatedRowHeight }

    self.circle = CircleView(frame: CGRect(
      x: 0,
      y: 0,
      width: 24,
      height: 24
    ))
    
    circle.isOpaque = false
    circle.translatesAutoresizingMaskIntoConstraints = false
    
    self.detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
    
    self.contentView.addSubview(circle)
    self.contentView.addConstraints([
      NSLayoutConstraint(
        item: circle,
        attribute: .centerY,
        relatedBy: .equal,
        toItem: self.contentView,
        attribute: .centerY,
        multiplier: 1,
        constant: 0),
      
      NSLayoutConstraint(
        item: circle,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: 24),
      NSLayoutConstraint(
        item: circle,
        attribute: .width,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: 24),
      NSLayoutConstraint(
        item: circle,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: circle.superview,
        attribute: .trailing,
        multiplier: 1,
        constant: -10),
//      NSLayoutConstraint(
//        item: self.contentView,
//        attribute: .height,
//        relatedBy: .equal,
//        toItem: nil,
//        attribute: .notAnAttribute,
//        multiplier: 1,
//        constant: 44),
      NSLayoutConstraint(
        item: self.detailTextLabel!,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: circle,
        attribute: .leading,
        multiplier: 1,
        constant: -10),
      NSLayoutConstraint(
        item: self.detailTextLabel!,
        attribute: .firstBaseline,
        relatedBy: .equal,
        toItem: self.textLabel,
        attribute: .firstBaseline,
        multiplier: 1,
        constant: 0),
      NSLayoutConstraint(
        item: self.detailTextLabel!,
        attribute: .centerY,
        relatedBy: .equal,
        toItem: self.contentView,
        attribute: .centerY,
        multiplier: 1,
        constant: 0),
      
      ])
  }
  
  
  
  public override func update() {
    self.textLabel?.text = row.title
    self.detailTextLabel?.text = row.value?.label ?? "None"
    self.circle.color = row.value?.color ?? UIColor.black
    self.layoutSubviews()
  }
}


final class ColorPickerPushRow: SelectorRow<ColorPickerCell, ColorPickerViewController>, RowType {
  public required init(tag: String?) {
    super.init(tag: tag)
    
    cellProvider = CellProvider<ColorPickerCell>()
    presentationMode = .show(controllerProvider: ControllerProvider.callback {
      
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let colorPickerVC =  storyboard.instantiateViewController(withIdentifier: "colorPickerViewController") as! ColorPickerViewController
      colorPickerVC.colors = self.options
      return colorPickerVC
      }, onDismiss: { vc in
        _ = vc.navigationController?.popViewController(animated: true)
    })
  }
}

@IBDesignable
class ColorPickerViewController: UICollectionViewController, TypedRowControllerType {
  
  var row: RowOf<ColorPaletteItem>! {
    didSet {
      if let cpi = row.value {
        self.collectionView?.selectItem(
          at: IndexPath(item: colors.index(of: cpi) ?? 0, section:0),
          animated: true,
          scrollPosition: .centeredVertically
        )
      }
    }
  }
  
  
  var colors:[ColorPaletteItem] = []
  
  public var onDismissCallback : ((UIViewController) -> ())?

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colors.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorPickerCollectionViewCell
    
    
    cell.label.text = colors[indexPath.item].label
    cell.circleView.color = colors[indexPath.item].color
    
    // Configure the cell
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  // Uncomment this method to specify if the specified item should be highlighted during tracking
  override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // Uncomment this method to specify if the specified item should be selected
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    row.value = self.colors[indexPath.item]
    self.navigationController?.popViewController(animated: true)
  }
  
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    return false
  }
  
  override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
  }
  
  
}
