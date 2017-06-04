import UIKit
import DynamicColor


protocol EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat
}

//Time interval cell => how much time between two consecutive events
class TimeIntervalStatCell : EventTypeStatCellBuilder {
  
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueSerieStatCell(for: ip)
    cell.formatter = SerieStatTableViewCell.timeIntervalFormatter
    cell.label.text = NSLocalizedString("stats/interval/label", comment: "Label for interval stat")
    cell.stats = vc.stats!.intervalsSerie!
    return cell
  }
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 220
  }
}

//Frequency by hours of day
class HoursOfDayStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell:GridStatTableViewCell = vc.dequeueGridStatCell(for:  ip)
    cell.label.text = NSLocalizedString("stats/frequency/hoursOfday", comment: "Frequency by hours")
    
    let statsByHours:[DateComponents : Float] = vc.stats!.countsProportions["hour"]!
    var values:[Float] = [Float](repeating: 0.0, count: 24)
    
    for (h, proportion) in statsByHours {
      values[h.hour!] = proportion
    }
    
    cell.grid.tintColor = DynamicColor(hexString: vc.eventType!.color!)
    cell.grid.numberOfCols = 12
    cell.grid.numberOfRows = 2
    cell.grid.values = values
    cell.grid.space = 1
    
    return cell
  }
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 140
  }
}

// Times per day => how many times an event occured in a single day
class TimesPerDayStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueSerieStatCell(for: ip)
    cell.stats = vc.stats!.countsSeries["day"]!
    cell.formatter = SerieStatTableViewCell.timesFormatter
    cell.label.text = NSLocalizedString("stats/timesPerDay/label", comment: "Label for times per day stat")
    return cell
  }
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 200
  }
}

class DateStatCell {

  func format(value:Date?) -> String {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    
    return (value != nil) ? df.string(from: value!) :
      NSLocalizedString("stats/lastTime/none", comment: "Placeholder used when no event of this type have happened yet")
  }
  
  func getDate(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> Date? {
    return nil
  }
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
//    let valueString = self.format(value: self.getDate(forViewController: vc, atIndexPath: ip)) as NSString
    return 120
  }
}

// Last time => first previous event
class LastTimeStatCell : DateStatCell, EventTypeStatCellBuilder {
  
  override func getDate(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> Date? {
    return vc.stats!.prevDate
  }
  
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueLabelStatCell(for: ip)
    cell.label.text = NSLocalizedString("stats/lastTime/label", comment: "Label for last time stat")
    cell.value.text = super.format(value: self.getDate(forViewController: vc, atIndexPath: ip))
    return cell
  }
}

// Next time => first previous event
class NextTimeStatCell : DateStatCell, EventTypeStatCellBuilder {
  
  override func getDate(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> Date? {
    return vc.stats!.nextDate
  }
  
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueLabelStatCell(for: ip)
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    cell.label.text = NSLocalizedString("stats/nextTime/label", comment: "Label for next time stat")
    cell.value.text = super.format(value: self.getDate(forViewController: vc, atIndexPath: ip))
    return cell
  }
}


class TimesPerWeekStatCell : EventTypeStatCellBuilder {
  
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueSerieStatCell(for: ip)
    cell.stats = vc.stats!.countsSeries["week"]!
    cell.formatter = SerieStatTableViewCell.timesFormatter
    cell.label.text = NSLocalizedString("stats/timesPerWeek/label", comment: "Label for times per week stat")
    return cell
  }

  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 180
  }
}

class TimesPerWeekdayStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueBarChartStatCell(for: ip)
    var values:[BarChartValue] = []
    let statsWeekdays:[DateComponents : Float] = vc.stats!.countsProportions["weekday"]!
    
    for (i, symbol) in Calendar.current.shortWeekdaySymbols.enumerated() {
      var bar = BarChartValue(label: symbol, value: 0)
      for (dc, proportion) in statsWeekdays{
        if i+1 == dc.weekday! {
          bar.value = proportion
        }
      }
      values.append(bar)
    }
    cell.label.text = NSLocalizedString("stats/timesPerWeekday/label",
                                        comment: "Label for times per weekday stat")
    cell.barChartView.values = values
    cell.barChartView.setNeedsLayout()
    return cell
  }
  
  
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 220
  }
}


class DayOfYearStatCell : EventTypeStatCellBuilder {
  func getHeight(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> CGFloat {
    return 120
  }
  
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueGridStatCell(for: ip)
    cell.grid.numberOfCols = 52
    cell.grid.numberOfRows = 7
    cell.grid.space = 1
    cell.grid.direction = GridStatLayoutDirection(first: .ttb, second: .ltr)
    cell.label.text = NSLocalizedString("stats/dayOfYear/label",
                                        comment: "Label for day of year stat")

    let cal = Calendar.current
    let components = cal.dateComponents([.year], from: Date())
    let firstDayOfCurrentYear:Date = cal.date(from: components)!
    let firstDayOfNextYear:Date = cal.date(byAdding:.year, value: 1, to: firstDayOfCurrentYear)!
    let lastDayOfCurrentYear:Date = cal.date(byAdding: .day, value: -1, to: firstDayOfNextYear)!
    let dates = DateUtils.generateDates(DateRange(from: firstDayOfCurrentYear, to: lastDayOfCurrentYear))
    
    var values:[Float] = []
    var offsets:[Int] = []
    var dayIndex:Int = 0
    dates.forEach { (cd) in
      let cdComps = cal.dateComponents([.year, .month, .day], from: cd.date)
      values.append(vc.stats!.countsProportions["dayOfYear"]![cdComps] ?? 0)
      
      if offsets.count < cdComps.month! {
        offsets.append(dayIndex)
      }
      
      dayIndex = dayIndex + 1
    }
    
    cell.grid.offsets = offsets
    cell.grid.values = values
    
    return cell
  }
}










