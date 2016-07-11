//
//  DimensionsViewController.swift
//  MadoSize
//
//  Created by Shad Sharma on 7/9/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa

class MadoPopoverController: NSViewController {
    @IBOutlet weak var xPosTextField: NSTextField!
    @IBOutlet weak var yPosTextField: NSTextField!
    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var centerButton: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!

    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var settingsMenu: NSMenu!
    
    var window: AppWindow?
    var monitor: AnyObject?

    convenience init(window: AppWindow?) {
        self.init(nibName: "MadoPopoverController", bundle: nil)!
        self.window = window
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        
        NSApp.activateIgnoringOtherApps(true)
        monitor = NSEvent.addGlobalMonitorForEventsMatchingMask([.LeftMouseDownMask, .RightMouseDownMask],
                                                                handler: self.cancelOperation)
    }
    
    override func viewWillDisappear() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        
        if let window = window {
            window.activateWithOptions(.ActivateIgnoringOtherApps)
        }
    }
    
    func enableControls(enabled: Bool) {
        xPosTextField.enabled = enabled
        yPosTextField.enabled = enabled
        widthTextField.enabled = enabled
        heightTextField.enabled = enabled
        centerButton.enabled = enabled
    }
    
    func load() {
        if let window = window, title = window.appTitle, position = window.position, size = window.size {
            enableControls(true)
            titleLabel.stringValue = title
            xPosTextField.integerValue = Int(position.x)
            yPosTextField.integerValue = Int(position.y)
            widthTextField.integerValue = Int(size.width)
            heightTextField.integerValue = Int(size.height)
        } else {
            titleLabel.stringValue = "No Active Window"
            enableControls(false)
        }
    }
    
    override func cancelOperation(sender: AnyObject?) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeDimensionsView(self)
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 53 {
            cancelOperation(self)
        }
        
        guard let window = window else {
            return
        }
        
        let hasControl = theEvent.modifierFlags.contains(.ControlKeyMask)
        let hasAlternate = theEvent.modifierFlags.contains(.AlternateKeyMask)
        let hasShift = theEvent.modifierFlags.contains(.ShiftKeyMask)
        let hasCommand = theEvent.modifierFlags.contains(.CommandKeyMask)
        
        let delta = hasShift ? 5 : 1
        
        if !hasControl && !hasAlternate && !hasCommand {
            if theEvent.keyCode == 123 {
                window.position = CGPoint(x: xPosTextField.integerValue - delta, y: yPosTextField.integerValue)
                load()
            } else if theEvent.keyCode == 124 {
                window.position = CGPoint(x: xPosTextField.integerValue + delta, y: yPosTextField.integerValue)
                load()
            } else if theEvent.keyCode == 125 {
                window.position = CGPoint(x: xPosTextField.integerValue, y: yPosTextField.integerValue + delta)
                load()
            } else if theEvent.keyCode == 126 {
                window.position = CGPoint(x: xPosTextField.integerValue, y: yPosTextField.integerValue - delta)
                load()
            }
        } else if !hasControl && hasAlternate && !hasCommand {
            if theEvent.keyCode == 123 {
                window.size = CGSize(width: widthTextField.integerValue - delta, height: heightTextField.integerValue)
                load()
            } else if theEvent.keyCode == 124 {
                window.size = CGSize(width: widthTextField.integerValue + delta, height: heightTextField.integerValue)
                load()
            } else if theEvent.keyCode == 125 {
                window.size = CGSize(width: widthTextField.integerValue, height: heightTextField.integerValue + delta)
                load()
            } else if theEvent.keyCode == 126 {
                window.size = CGSize(width: widthTextField.integerValue, height: heightTextField.integerValue - delta)
                load()
            }
        }
    }

    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }

    @IBAction func showSettingsMenu(sender: AnyObject) {
        NSMenu.popUpContextMenu(settingsMenu, withEvent: NSApp.currentEvent!, forView: settingsButton)
    }
    
    @IBAction func positionFieldChanged(sender: NSTextField) {
        guard let window = window else {
            return
        }

        window.position = CGPoint(x: xPosTextField.integerValue, y: yPosTextField.integerValue)
        load()
    }
    
    @IBAction func sizeFieldChanged(sender: NSTextField) {
        guard let window = window else {
            return
        }
        
        window.size = CGSize(width: widthTextField.integerValue, height: heightTextField.integerValue)
        load()
    }

    @IBAction func centerWindow(sender: AnyObject) {
        guard let window = window else {
            return
        }
        
        window.center()
        load()
    }

    @IBAction func maximizeWindow(sender: AnyObject) {
        guard let window = window else {
            return
        }
        
        window.maximize()
        load()
    }
}
