//
//  ColorSwatchPreviewCollectionViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 09/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor
private let reuseIdentifier = "colorCell"

class ColorSwatchPreviewCollectionViewController:UICollectionViewController {
  
  @IBOutlet weak var buyButton: UIBarButtonItem!
  
  @IBAction func buyColorSwatch(_ sender: Any) {
    if let cs = colorSwatch {
      IAPManager.shared.buyAdditionalColorSwatch(id: cs.productID) {
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  var colorSwatch:ColorSwatch? {
    didSet {
      self.buyButton.isEnabled = IAPManager.shared.activeColorSwatchesIds.contains(colorSwatch?.productID! ?? "") == false
      colorSwatch?.load {
        self.collectionView?.reloadData()
      }
    }
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let cs = colorSwatch {
      return cs.colors.count
    }
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    let circle = cell.contentView.subviews.first as! CircleView
    circle.strokeWidth = 2
    if let cs = colorSwatch {
      circle.color = cs.colors[indexPath.item].color
      circle.strokeColor = cs.colors[indexPath.item].color.darkened()
    } else {
      circle.color = UIColor.clear
      circle.strokeColor = UIColor.clear
    }
    return cell
  }
}
