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
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var resizeButtons: NSSegmentedControl!
    @IBOutlet weak var realignButtons: NSSegmentedControl!

    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var settingsMenu: NSMenu!
    
    var window: AppWindow?
    var timer: NSTimer?

    convenience init(window: AppWindow?) {
        self.init(nibName: "MadoPopoverController", bundle: nil)!
        self.window = window
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load(self)
        
        NSApp.activateIgnoringOtherApps(true)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(updateWindow), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func enableControls(enabled: Bool) {
        xPosTextField.enabled = enabled
        yPosTextField.enabled = enabled
        widthTextField.enabled = enabled
        heightTextField.enabled = enabled
        resizeButtons.enabled = enabled
        realignButtons.enabled = enabled
    }
    
    func updateWindow(sender: AnyObject?) {
        let window = AppWindow.frontmost()
        if window?.appTitle != "MadoSize" {
            self.window = window
            load(sender)
        }
    }
    
    func load(sender: AnyObject?) {
        if let window = window, title = window.appTitle, frame = window.frame {
            enableControls(true)
            titleLabel.stringValue = title
            rect = frame
        } else {
            titleLabel.stringValue = "No Active Window"
            enableControls(false)
        }
    }
    
    var rect: CGRect {
        get {
            let origin = CGPoint(x: xPosTextField.integerValue, y: yPosTextField.integerValue)
            let size = CGSize(width: widthTextField.integerValue, height: heightTextField.integerValue)
            return CGRect(origin: origin, size: size)
        }
        
        set {
            xPosTextField.integerValue = Int(newValue.origin.x)
            yPosTextField.integerValue = Int(newValue.origin.y)
            widthTextField.integerValue = Int(newValue.size.width)
            heightTextField.integerValue = Int(newValue.size.height)
        }
    }
    
    func close(sender: AnyObject?) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeDimensionsView(sender)
        }
    }
    
    func reactivate(sender: AnyObject?) {
        if let window = window {
            window.activateWithOptions(.ActivateIgnoringOtherApps)
        }
    }
    
    override func cancelOperation(sender: AnyObject?) {
        reactivate(sender)
        close(sender)
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
        
        let r = rect
        let delta: CGFloat = hasShift ? 5 : 1
        
        if !hasControl && !hasAlternate && !hasCommand {
            if theEvent.keyCode == 123 {
                window.frame = CGRect(origin: CGPoint(x: r.origin.x - delta, y: r.origin.y), size: r.size)
                load(theEvent)
            } else if theEvent.keyCode == 124 {
                window.frame = CGRect(origin: CGPoint(x: r.origin.x + delta, y: r.origin.y), size: r.size)
                load(theEvent)
            } else if theEvent.keyCode == 125 {
                window.frame = CGRect(origin: CGPoint(x: r.origin.x, y: r.origin.y - delta), size: r.size)
                load(theEvent)
            } else if theEvent.keyCode == 126 {
                window.frame = CGRect(origin: CGPoint(x: r.origin.x, y: r.origin.y + delta), size: r.size)
                load(theEvent)
            }
        } else if !hasControl && hasAlternate && !hasCommand {
            if theEvent.keyCode == 123 {
                window.frame = CGRect(origin: r.origin, size: CGSize(width: r.size.width - delta, height: r.size.height))
                load(theEvent)
            } else if theEvent.keyCode == 124 {
                window.frame = CGRect(origin: r.origin, size: CGSize(width: r.size.width + delta, height: r.size.height))
                load(theEvent)
            } else if theEvent.keyCode == 125 {
                window.frame = CGRect(origin: r.origin, size: CGSize(width: r.size.width, height: r.size.height - delta))
                load(theEvent)
            } else if theEvent.keyCode == 126 {
                window.frame = CGRect(origin: r.origin, size: CGSize(width: r.size.width, height: r.size.height + delta))
                load(theEvent)
            }
        }
    }

    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }

    @IBAction func showSettingsMenu(sender: AnyObject) {
        NSMenu.popUpContextMenu(settingsMenu, withEvent: NSApp.currentEvent!, forView: settingsButton)
    }
    
    @IBAction func fieldChanged(sender: NSTextField) {
        guard let window = window else {
            return
        }
        
        window.frame = rect
        load(sender)
    }

    @IBAction func realignClicked(sender: NSSegmentedControl) {
        guard let window = window else {
            return
        }
        
        switch sender.selectedSegment {
        case 0:
            window.center()
        case 1:
            window.alignLeft()
        case 2:
            window.alignRight()
        case 3:
            window.alignUp()
        case 4:
            window.alignDown()
        default:
            print("Unknown button value: \(sender.selectedSegment)")
        }
        
        load(sender)
    }

    @IBAction func resizeClicked(sender: NSSegmentedControl) {
        guard let window = window else {
            return
        }
        
        switch sender.selectedSegment {
        case 0:
            window.maximize()
        case 1:
            window.maximizeHorizontal()
        case 2:
            window.maximizeVertical()
        default:
            print("Unknown button value: \(sender.selectedSegment)")
        }
        
        load(sender)
    }
}
