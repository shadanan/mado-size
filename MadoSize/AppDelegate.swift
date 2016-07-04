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
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.title = "M"
        statusItem.menu = statusItemMenu
        
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
}

