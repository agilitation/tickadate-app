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
    
    self.detailTextLabel!.frame.origin.x = self.detailTextLabel!.frame.origin.x - 10
    self.accessoryView = circle
  }
  
  public override func update() {
    self.textLabel?.text = row.title
    self.detailTextLabel?.text = row.value?.label  ?? ""
    self.circle.color = row.value?.color ?? UIColor.black
    self.setNeedsLayout()
  }
}


class CircleAccessoryView:UIView {
  

}


final class ColorPickerPushRow: SelectorRow<ColorPickerCell, ColorPickerViewController>, RowType {
  public required init(tag: String?) {
    super.init(tag: tag)
    
    cellProvider = CellProvider<ColorPickerCell>()
    presentationMode = .show(controllerProvider: ControllerProvider.callback {
      
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let colorPickerVC =  storyboard.instantiateViewController(withIdentifier: "colorPickerViewController") as! ColorPickerViewController

      return colorPickerVC
      }, onDismiss: { vc in
        _ = vc.navigationController?.popViewController(animated: true)
    })
  }
}

@IBDesignable
class ColorPickerViewController: UICollectionViewController, TypedRowControllerType {
  
  var row: RowOf<ColorPaletteItem>!
  {
    didSet {
      if let cpi = row.value, let ip = self.indexPath(ofColorPaletteItem: cpi) {
        self.collectionView?.selectItem(
          at: ip,
          animated: true,
          scrollPosition: .centeredVertically
        )
      }
    }
  }

  
  func indexPath(ofColorPaletteItem cpi:ColorPaletteItem) -> IndexPath? {
    for (section, colorSwatch) in swatches.enumerated() {
      for (item, color) in colorSwatch.colors.enumerated() {
        if color == cpi {
          return IndexPath(item: item, section: section)
        }
      }
    }
    return nil
  }
    
  var swatches:[ColorSwatch] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    reload()
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name("colorSwatches.change"), object: nil, queue: nil) { (notif) in
      self.reload()
    }
  }
  
  
  func reload() {
    let dg = DispatchGroup()

    ColorSwatchesManager.shared.fetchActiveColorSwatches { (swatches) in
      swatches.forEach({ (cs) in
        dg.enter()
        cs.load(completion: dg.leave)
      })
      dg.notify(queue: DispatchQueue.main, execute: {
        self.swatches = swatches
        self.collectionView?.reloadData()
      })
    }
  }
  
  
  public var onDismissCallback : ((UIViewController) -> ())?

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return swatches.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath)
    let label = view.subviews[0] as! UILabel
    label.text = swatches[indexPath.section].name
    return view
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return swatches[section].colors.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorPickerCollectionViewCell
    let cpi = swatches[indexPath.section].colors[indexPath.item]
    cell.label.text = cpi.label
    cell.circleView.color = cpi.color
    cell.isSelected = cpi == row.value ?? nil
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
    row.value = self.swatches[indexPath.section].colors[indexPath.item]
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
