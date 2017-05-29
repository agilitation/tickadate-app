import UIKit
import DynamicColor


protocol EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell
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
}

// Times per day => how many times an event occured in a single day
class TimesPerDayStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueSerieStatCell(for: ip)
    cell.stats = vc.stats!.countsSeries["day"]!
    cell.label.text = NSLocalizedString("stats/timesPerDay/label", comment: "Label for times per day stat")
    return cell
  }
}

// Last time => first previous event
class LastTimeStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueLabelStatCell(for: ip)
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    cell.label.text = NSLocalizedString("stats/lastTime/label", comment: "Label for last time stat")
    cell.value.text = (vc.stats!.prevDate != nil) ?
      df.string(from: vc.stats!.prevDate!) :
      NSLocalizedString("stats/lastTime/none",
                        comment: "Placeholder used when no event of this type have happened yet")
    return cell
  }
}

// Next time => first previous event
class NextTimeStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueLabelStatCell(for: ip)
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    cell.label.text = NSLocalizedString("stats/nextTime/label", comment: "Label for next time stat")
    cell.value.text = (vc.stats!.nextDate != nil) ?
      df.string(from: vc.stats!.nextDate!) :
      NSLocalizedString("stats/nextTime/none",
                        comment: "Placeholder used when no event of this type are note expected yet")
    return cell
  }
}


class TimesPerWeekStatCell : EventTypeStatCellBuilder {
  func getCell(forViewController vc: StatsTableViewController, atIndexPath ip: IndexPath) -> StatTableViewCell {
    let cell = vc.dequeueSerieStatCell(for: ip)
    cell.stats = vc.stats!.countsSeries["week"]!
    cell.label.text = NSLocalizedString("stats/timesPerWeek/label", comment: "Label for times per week stat")
    return cell
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
}
