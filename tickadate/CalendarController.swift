//
//  CalendarDataSource.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor


protocol CalendarControllerDelegate {
  
  func calendarController(_ calendarController: CalendarController, didSelectDate date: Date)
  
  func calendarController(_ calendarController: CalendarController, setVisibleMonth monthAndYear: DateComponents)
  
}

class CalendarController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var dates : [CalendarDate] = []
  var delegate:CalendarControllerDelegate?
  var interval:Int = 1
  var calendar: Calendar = Calendar.current
  var formatter: DateFormatter = DateFormatter()
  var dateRange:DateRange!
  var viewportSize:CGSize?
  var todayIndex:Int! = 0
  var selectedEventType:EventType?
  var selectedIndexPath:IndexPath!
  var dataController:DataController! = DataController()
  var visibleMonthAndYear:DateComponents!
  var cellSize:CGSize! = CGSize(width: 45, height: 60)
  
  
  var events: [Event] = []
  {
    didSet {
      collectionView?.reloadItems(at: [selectedIndexPath])
    }
  }
  
  func indexPath(forDate date:Date) -> IndexPath? {
    for (index, cd) in dates.enumerated() {
      if Calendar.current.isDate(cd.date, inSameDayAs: date) {
        return IndexPath(item: index, section: 0)
      }
    }
    return nil
  }
  
  func select(date:Date){
    if let ip = indexPath(forDate: date){
      collectionView?.selectItem(at: ip, animated: true, scrollPosition: .centeredVertically)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewportSize = collectionView?.bounds.size
    self.generateDates()
    self.scrollToToday(animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    viewportSize = collectionView?.bounds.size
  }
  
  func generateDates(){
    dates = DateUtils.generateDates(DateRange(rangeAround: Date(), component: .year, value: 1))
    for (index, cd) in dates.enumerated() {
      if cd.isToday {
        todayIndex = index
        if selectedIndexPath == nil {
          selectedIndexPath = IndexPath(item: index, section:0)
        }
      }
    }
  }
  
  
  func getEvents(forDate:Date) -> [Event]{
    var results:[Event] = []
    for event in events {
      if calendar.isDate(event.date! as Date, inSameDayAs: forDate){
        results.append(event)
      }
    }
    return results
  }
  
  override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CalendarDateCell
    let events:[Event] = getEvents(forDate: self.dates[indexPath.item].date)
    var dots:[String] = []
    
    events.forEach({
      dots.append($0.type?.color ?? "000000")
    })
    
    cell.setDate(self.dates[indexPath.item])
    cell.setEventDots(dots)
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.dates.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    self.delegate?.calendarController(self, didSelectDate: self.dates[indexPath.item].date)
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let cv = collectionView {
      var visibleRect = CGRect()
      visibleRect.origin = cv.contentOffset
      visibleRect.size = cv.bounds.size
      let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
      let visibleIndexPath: IndexPath = cv.indexPathForItem(at: visiblePoint) ?? IndexPath(item: 0, section: 0)
      let visibleDate = dates[visibleIndexPath.item].date!
      
      self.visibleMonthAndYear = calendar.dateComponents([.month, .year], from: visibleDate)
      self.delegate?.calendarController(self, setVisibleMonth: visibleMonthAndYear)
    }
  }
  
  // todo scrollviewendscrollanimation => change visible month
  
  func scrollToToday(animated:Bool = true) {
    self.collectionView?.layoutIfNeeded()
    self.collectionView?.scrollToItem(
      at: IndexPath(item: todayIndex, section: 0),
      at: UICollectionViewScrollPosition.centeredVertically,
      animated: animated
    )
    self.viewWillLayoutSubviews()
  }
  
  // Updates collectionView width to make the division by 7 pixel perfect
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    let w:CGFloat! = self.collectionView!.bounds.width
    let h:CGFloat! = self.collectionView!.bounds.height
    
    let newWidth:CGFloat! = floor(w/7) * 7
    cellSize.width = newWidth/7
    collectionView?.frame = CGRect(
      x: (w - newWidth) / 2,
      y: 0,
      width: newWidth,
      height: h
    )
  }
  
  
  //    INFINITE SCROLL... kinda
  //    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
  //        let offsetY = scrollView.contentOffset.y
  //        let contentHeight = scrollView.contentSize.height
  //
  //        if offsetY > contentHeight - scrollView.frame.size.height {
  //            self.dateRange.to = calendar.date(byAdding: .month, value: +interval, to: self.dateRange.to)
  //            self.updateDates()
  //        } else if(offsetY < 0){
  //            self.dateRange.from = calendar.date(byAdding: .month, value: -interval, to: self.dateRange.from)
  //            self.updateDates()
  //        } else {
  //            self.updating = false;
  //        }
  //    }
}
