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
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusItem")
            button.action = #selector(toggleDimensionsView)
        }
    }
    
    func showDimensionsView(_ sender: AnyObject?) {
        if let button = statusItem.button {
            let appWindow = AppWindow.frontmost()

            let dimensionsView = NSPopover()
            dimensionsView.contentViewController = MadoPopoverController(window: appWindow)
            dimensionsView.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            self.dimensionsView = dimensionsView
        }
    }
    
    func closeDimensionsView(_ sender: AnyObject?) {
        if let dimensionsView = dimensionsView, let popoverController = dimensionsView.contentViewController as? MadoPopoverController {
            popoverController.reactivate(sender)
            dimensionsView.performClose(sender)
        }

        dimensionsView = nil
    }
    
    func toggleDimensionsView(_ sender: AnyObject?) {
        if dimensionsView == nil {
            showDimensionsView(sender)
        } else {
            closeDimensionsView(sender)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Insert code here to tear down your application
    }
}

