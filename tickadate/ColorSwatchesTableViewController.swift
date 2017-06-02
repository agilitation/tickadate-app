//
//  ColorSwatchesTableViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 01/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class ColorSwatchesTableViewController: UITableViewController {
  
  var swatches:[ColorSwatchDescription] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let fileUrl = Bundle.main.url(forResource: "ColorSwatches", withExtension: "plist"),  let data = try? Data(contentsOf: fileUrl) {
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String:String]] {
        result?.forEach({ (colorSwatchPListDict) in
          self.swatches.append(ColorSwatchDescription(fromPList: colorSwatchPListDict))
        })
        
      }
    }
    
    tableView.reloadData()
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return swatches.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ColorSwatchTableViewCell
    
    let csd:ColorSwatchDescription = self.swatches[indexPath.item]
    cell.nameLabel.text = csd.name
    cell.descriptionLabel.text = csd.description
    //cell.buyButton.titleLabel = GET PRICE FROM productID
    
    return cell
  }
}
