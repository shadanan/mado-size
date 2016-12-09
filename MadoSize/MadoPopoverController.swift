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
    var timer: Timer?

    convenience init(window: AppWindow?) {
        self.init(nibName: "MadoPopoverController", bundle: nil)!
        self.window = window
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load(self)
        
        NSApp.activate(ignoringOtherApps: true)
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateWindow), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func enableControls(_ enabled: Bool) {
        xPosTextField.isEnabled = enabled
        yPosTextField.isEnabled = enabled
        widthTextField.isEnabled = enabled
        heightTextField.isEnabled = enabled
        resizeButtons.isEnabled = enabled
        realignButtons.isEnabled = enabled
    }
    
    func updateWindow(_ sender: AnyObject?) {
        let window = AppWindow.frontmost()
        if window?.appTitle != "MadoSize" {
            self.window = window
            load(sender)
        }
    }
    
    func load(_ sender: AnyObject?) {
        if let window = window, let title = window.appTitle, let frame = window.frame {
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
    
    func close(_ sender: AnyObject?) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeDimensionsView(sender)
        }
    }
    
    func reactivate(_ sender: AnyObject?) {
        if let window = window {
            window.activateWithOptions(.activateIgnoringOtherApps)
        }
    }
    
    override func cancelOperation(_ sender: Any?) {
        reactivate(sender as AnyObject?)
        close(sender as AnyObject?)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if theEvent.keyCode == 53 {
            cancelOperation(self)
        }
        
        guard let window = window else {
            return
        }
        
        let hasControl = theEvent.modifierFlags.contains(.control)
        let hasAlternate = theEvent.modifierFlags.contains(.option)
        let hasShift = theEvent.modifierFlags.contains(.shift)
        let hasCommand = theEvent.modifierFlags.contains(.command)
        
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

    @IBAction func quitApplication(_ sender: AnyObject) {
        NSApp.terminate(self)
    }

    @IBAction func showSettingsMenu(_ sender: AnyObject) {
        NSMenu.popUpContextMenu(settingsMenu, with: NSApp.currentEvent!, for: settingsButton)
    }
    
    @IBAction func fieldChanged(_ sender: NSTextField) {
        guard let window = window else {
            return
        }
        
        window.frame = rect
        load(sender)
    }

    @IBAction func realignClicked(_ sender: NSSegmentedControl) {
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

    @IBAction func resizeClicked(_ sender: NSSegmentedControl) {
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
