//
//  AppDelegate.swift
//  DayBattery
//
//  Created by Daniyar Karbayev on 18/04/23.
//  Copyright © 2018 Dan Karbayev. All rights reserved.
//

import Cocoa


fileprivate let modeKey = "selectedMode"
fileprivate let formatKey = "selectedFormat"
fileprivate let dayStartKey = "selectedDayStart"

enum Format: Int {
  case percent
  case short
  case long
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesDelegate {

  enum Mode: Int {
    case day
    case month
    case year
  }


  let statusItem = NSStatusBar.system.statusItem(withLength: -1)
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var dayItem: NSMenuItem!
  @IBOutlet weak var monthItem: NSMenuItem!
  @IBOutlet weak var yearItem: NSMenuItem!


  var preferencesWindowController: PreferencesWindowController?


  var currentMode: Mode = .year {
    didSet {
      UserDefaults.standard.set(self.currentMode.rawValue, forKey: modeKey)
      self.dayItem.state = .off
      self.monthItem.state = .off
      self.yearItem.state = .off
      switch self.currentMode {
      case .day:
        self.dayItem.state = .on
      case .month:
        self.monthItem.state = .on
      case .year:
        self.yearItem.state = .on
      }
      self.tick()
    }
  }

  var currentFormat: Format = .long {
    didSet {
      UserDefaults.standard.set(self.currentFormat.rawValue, forKey: formatKey)
      self.tick()
    }
  }

  var currentDayStart: Int = 0 {
    didSet {
      UserDefaults.standard.set(self.currentDayStart, forKey: dayStartKey)
      self.tick()
    }
  }


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem.title = ""
    statusItem.menu = statusMenu

    Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    let mode = UserDefaults.standard.integer(forKey: modeKey)
    self.currentMode = Mode(rawValue: mode) ?? .day
    let format = UserDefaults.standard.integer(forKey: formatKey)
    self.currentFormat = Format(rawValue: format) ?? .long
    self.currentDayStart = UserDefaults.standard.integer(forKey: dayStartKey)
  }


  // MARK: - Status Bar Menu

  @objc func tick() {
    let dayProgress = self.progress(forMode: .day)
    self.dayItem.title = self.text(forMode: .day, progress: dayProgress, withFormat: .long)
    let monthProgress = self.progress(forMode: .month)
    self.monthItem.title = self.text(forMode: .month, progress: monthProgress, withFormat: .long)
    let yearProgress = self.progress(forMode: .year)
    self.yearItem.title = self.text(forMode: .year, progress: yearProgress, withFormat: .long)

    self.statusItem.title = self.text(forMode: self.currentMode, progress: self.progress(forMode: self.currentMode), withFormat: self.currentFormat)
  }


  @IBAction func changeMode(_ sender: NSMenuItem) {
    switch sender {
    case self.dayItem:
      self.currentMode = .day
    case self.monthItem:
      self.currentMode = .month
    case self.yearItem:
      self.currentMode = .year
    default:
      return
    }
  }


  @IBAction func openPreferences(_ sender: Any) {
    if self.preferencesWindowController == nil {
      self.preferencesWindowController = PreferencesWindowController(windowNibName: NSNib.Name("Preferences"))
      self.preferencesWindowController?.delegate = self
    }
    self.preferencesWindowController?.window?.makeKeyAndOrderFront(self)
    self.preferencesWindowController?.formatPopup.selectItem(at: self.currentFormat.rawValue)
    self.preferencesWindowController?.dayStartPopup.selectItem(at: self.currentDayStart)
    NSApplication.shared.activate(ignoringOtherApps: true)
  }


  @IBAction func quit(_ sender: Any) {
    NSApplication.shared.terminate(self)
  }


  // MARK: - Calculation

  func text(forMode mode: Mode, progress: Int, withFormat format: Format) -> String {
    let name = self.name(forMode: mode)
    switch format {
    case .percent:
      return String(format: "%d%%", progress)
    case .short:
      return String(format: "%@: %d%%", String(name[name.startIndex]), progress)
    case .long:
      return String(format: "%@: %d%%", name, progress)
    }
  }


  func name(forMode mode: Mode) -> String {
    switch mode {
    case .year:
      return "Year"
    case .month:
      return "Month"
    case .day:
      return "Day"
    }
  }


  func progress(forMode mode: Mode) -> Int {
    let calendar = Calendar.current
    let now = Date()
    guard let adjustedNow = calendar.date(byAdding: .hour, value: -self.currentDayStart, to: now) else { return 0 }
    let components = calendar.dateComponents(self.components(forMode: mode), from: adjustedNow)
    guard let start = calendar.date(from: components) else { return 0 }
    guard let next = calendar.date(byAdding: self.nextComponent(forMode: mode), value: 1, to: start) else { return 0 }
    guard let end = calendar.date(byAdding: .second, value: -1, to: next) else { return 0 }

    let current = adjustedNow.timeIntervalSince(start)
    let total = end.timeIntervalSince(start)
    let progress = current / total * 100
    return Int(progress)
  }


  func components(forMode mode: Mode) -> Set<Calendar.Component> {
    switch mode {
    case .year:
      return [.year]
    case .month:
      return [.year, .month]
    case .day:
      return [.year, .month, .day]
    }
  }


  func nextComponent(forMode mode: Mode) -> Calendar.Component {
    switch mode {
    case .year:
      return .year
    case .month:
      return .month
    case .day:
      return .day
    }
  }


  // MARK: - Preferences

  func preferencesWindowDidClose(_ windowController: PreferencesWindowController) {
    self.preferencesWindowController = nil
  }


  func preferencesWindow(_ windowController: PreferencesWindowController, didChangeFormat format: Format) {
    self.currentFormat = format
  }


  func preferencesWindow(_ windowController: PreferencesWindowController, didChangeDayStart startHour: Int) {
    self.currentDayStart = startHour
  }

}

