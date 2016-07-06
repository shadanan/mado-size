//
//  AppDelegate.swift
//  MadoSize
//
//  Created by Shad Sharma on 6/28/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    @IBOutlet weak var statusItemMenu: NSMenu!
    @IBOutlet weak var windowTitleMenuItem: NSMenuItem!
    @IBOutlet weak var windowDimensionsMenuItem: NSMenuItem!

    var statusItem: NSStatusItem!
    var setDimensionsDialog: SetDimensionsController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "StatusItem")
        statusItem.menu = statusItemMenu
        statusItemMenu.autoenablesItems = false
        
        NSEvent.addGlobalMonitorForEventsMatchingMask(.KeyDownMask, handler: self.globalKeyDown)
    }
    
    func globalKeyDown(theEvent: NSEvent) {
        guard let char = theEvent.charactersIgnoringModifiers else {
            return
        }

        let hasControl = theEvent.modifierFlags.contains(.ControlKeyMask)
        let hasAlternate = theEvent.modifierFlags.contains(.AlternateKeyMask)
        let hasShift = theEvent.modifierFlags.contains(.ShiftKeyMask)
        let hasCommand = theEvent.modifierFlags.contains(.CommandKeyMask)
        
        print("keyCode: \(hasControl ? "⌃" : "")\(hasAlternate ? "⌥" : "")\(hasShift ? "⇧" : "")\(hasCommand ? "⌘" : "")\(char)")
        
        guard char == "d" && hasControl && hasAlternate && hasCommand && !hasShift else {
            return
        }
        
        guard let frontmostWindow = AccessibilityElement.frontmostWindowElement() else {
            return
        }
        
        print("position=\(frontmostWindow.position()!), size=\(frontmostWindow.size()!)")
        
        frontmostWindow.setPosition(CGPoint(x: 58, y: 48))
        frontmostWindow.setSize(CGSize(width: 1280, height: 774))
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        // Insert code here to tear down your application
    }
    
    func menuWillOpen(menu: NSMenu) {
        guard
            let window = AccessibilityElement.frontmostWindowElement(),
            title = window.title(),
            position = window.position(),
            size = window.size() else {
                windowTitleMenuItem.title = "No Window Has Focus"
                windowTitleMenuItem.enabled = false
                windowDimensionsMenuItem.title = "Origin: (-, -), Size: (-, -)"
                return
        }
        
        windowTitleMenuItem.title = "Set Dimensions of \(title)..."
        windowTitleMenuItem.enabled = true
        windowDimensionsMenuItem.title = "Origin: (\(Int(position.x)), \(Int(position.y))), Size: (\(Int(size.width)), \(Int(size.height)))"
    }

    @IBAction func copyWindowDimensions(sender: NSMenuItem) {
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(windowDimensionsMenuItem.title, forType: NSStringPboardType)
    }

    @IBAction func setWindowDimensions(sender: NSMenuItem) {
        guard
            let window = AccessibilityElement.frontmostWindowElement(),
            position = window.position(),
            size = window.size() else {
                return
        }

        let currentApp = NSWorkspace.sharedWorkspace().frontmostApplication
        NSApp.activateIgnoringOtherApps(true)
        
        setDimensionsDialog = SetDimensionsController(position: position, size: size)
        
        if let dialogWindow = setDimensionsDialog.window {
            let result = NSApp.runModalForWindow(dialogWindow)
            print("Result: \(result)")
        }
        
        if let currentApp = currentApp {
            currentApp.activateWithOptions(.ActivateAllWindows)
        }
    }
}

