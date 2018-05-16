//
//  PreferencesWindow.swift
//  DayBattery
//
//  Created by Daniyar Karbayev on 18/04/24.
//  Copyright © 2018 Dan Karbayev. All rights reserved.
//

import Cocoa

protocol PreferencesDelegate: class {
  func preferencesWindow(_ windowController: PreferencesWindowController, didChangeFormat format: Format)
  func preferencesWindow(_ windowController: PreferencesWindowController, didChangeDayStart startHour: Int)
  func preferencesWindowDidClose(_ windowController: PreferencesWindowController)
}

class PreferencesWindowController: NSWindowController {

  @IBOutlet weak var formatPopup: NSPopUpButton!
  @IBOutlet weak var dayStartPopup: NSPopUpButton!


  weak var delegate: PreferencesDelegate?


  override func windowDidLoad() {
    super.windowDidLoad()

    let start = Calendar.current.startOfDay(for: Date())
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.autoupdatingCurrent)
    for i in 0..<24 {
      let item = NSMenuItem()
      if let next = Calendar.current.date(byAdding: .hour, value: i, to: start) {
        item.title = formatter.string(from: next)
      } else {
        item.title = "\(i)"
      }
      self.dayStartPopup.menu?.addItem(item)
    }
    self.window?.delegate = self
  }


  @IBAction func changeFormat(_ sender: NSPopUpButton) {
    let index = sender.indexOfSelectedItem
    if let format = Format(rawValue: index) {
      self.delegate?.preferencesWindow(self, didChangeFormat: format)
    }
  }


  @IBAction func changeDayStart(_ sender: NSPopUpButton) {
    let index = sender.indexOfSelectedItem
    self.delegate?.preferencesWindow(self, didChangeDayStart: index)
  }
}


extension PreferencesWindowController: NSWindowDelegate {

  func windowWillClose(_ notification: Notification) {
    self.delegate?.preferencesWindowDidClose(self)
  }

}
