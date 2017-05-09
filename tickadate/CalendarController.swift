//
//  CalendarDataSource.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

struct CalendarDate {
    var date:Date!
    var formatted:String!
    var today:Bool! = false
    
    init(date:Date, formatted:String) {
        self.date = date
        self.formatted = formatted
        self.today = Calendar.current.isDateInToday(date)
    }
}

struct DateRange {
    var from:Date!
    var to:Date!
}

class CalendarController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dates : [CalendarDate] = []
    
    var interval:Int = 2
    var calendar: Calendar = Calendar.current
    var formatter: DateFormatter = DateFormatter()
    var dateRange:DateRange = DateRange()
    var updating:Bool = false
    var viewportSize:CGSize?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let today:Date! = self.calendar.startOfDay(for: Date());
        self.dateRange.from = calendar.date(byAdding: .month, value: -interval, to: today)
        self.dateRange.to = calendar.date(byAdding: .month, value: interval, to: today)
        viewportSize = collectionView?.bounds.size
        self.updateDates()
    }
    
    func updateDates(){
        self.updating = true;
        self.generateDates(self.dateRange)
        self.collectionView?.reloadData()
    }
    
    func generateDates(_ dr:DateRange){
        self.dates.removeAll();
        var tempDate:Date! = dr.from;
        let numberOfDays =  self.calendar.dateComponents([.day], from: dr.from, to: dr.to).day!
        
        formatter.dateFormat = "dd"
        
        for _ in 1...numberOfDays{
            tempDate =  self.calendar.date(byAdding: .day, value: 1, to: tempDate)
            self.dates.append(CalendarDate(date:tempDate, formatted: formatter.string(from: tempDate)))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CalendarDateCell
        cell.calendarDate = self.dates[indexPath.item]
        return cell
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dates.count
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            self.dateRange.to = calendar.date(byAdding: .month, value: +interval, to: self.dateRange.to)
            self.updateDates()
        } else if(offsetY < 0){
            self.dateRange.from = calendar.date(byAdding: .month, value: -interval, to: self.dateRange.from)
            self.updateDates()
        } else {
            self.updating = false;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size:CGSize = CGSize(width: collectionView.bounds.width/7, height: 50);
        
        return size;

    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let w:CGFloat! = self.collectionView!.bounds.width
        let h:CGFloat! = self.collectionView!.bounds.height
        
        collectionView?.frame = CGRect(
            x: 0,
            y: 0,
            width: floor(w/7) * 7,
            height: h
        );

    }
    

}
