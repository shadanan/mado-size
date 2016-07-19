//
//  AppDelegate.swift
//  MadoSize
//
//  Created by Shad Sharma on 6/28/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var dimensionsView: NSPopover?
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusItem")
            button.action = #selector(toggleDimensionsView)
        }
    }
    
    func showDimensionsView(sender: AnyObject?) {
        if let button = statusItem.button {
            let appWindow = AppWindow.frontmost()

            let dimensionsView = NSPopover()
            dimensionsView.contentViewController = MadoPopoverController(window: appWindow)
            dimensionsView.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
            self.dimensionsView = dimensionsView
        }
    }
    
    func closeDimensionsView(sender: AnyObject?) {
        if let dimensionsView = dimensionsView, popoverController = dimensionsView.contentViewController as? MadoPopoverController {
            popoverController.reactivate(sender)
            dimensionsView.performClose(sender)
        }

        dimensionsView = nil
    }
    
    func toggleDimensionsView(sender: AnyObject?) {
        if dimensionsView == nil {
            showDimensionsView(sender)
        } else {
            closeDimensionsView(sender)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        
        // Insert code here to tear down your application
    }
}

