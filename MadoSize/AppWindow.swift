//
//  AccessibilityElement.swift
//  MadoSize
//
//  Created by Shad Sharma on 7/3/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa
import Foundation

class AppWindow {
    let app: NSRunningApplication
    let appElement: AXUIElementRef
    let windowElement: AXUIElementRef
    
    static func frontmost() -> AppWindow? {
        guard let frontmostApplication = NSWorkspace.sharedWorkspace().frontmostApplication else {
            return nil
        }
        
        let appElement = AXUIElementCreateApplication(frontmostApplication.processIdentifier).takeRetainedValue()

        var result: AnyObject?
        guard AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute, &result) == .Success else {
            return nil
        }
        
        let windowElement = result as! AXUIElementRef
        return AppWindow(app: frontmostApplication, appElement: appElement, windowElement: windowElement)
    }
    
    var primaryScreenHeight: CGFloat {
        get {
            if let screens = NSScreen.screens() {
                return screens[0].frame.maxY
            } else {
                return 0
            }
        }
    }
    
    init(app: NSRunningApplication, appElement: AXUIElementRef, windowElement: AXUIElementRef) {
        self.app = app
        self.appElement = appElement
        self.windowElement = windowElement
    }
    
    private func value(attribute: String, type: AXValueType) -> AXValueRef? {
        guard CFGetTypeID(windowElement) == AXUIElementGetTypeID() else {
            return nil
        }
        
        var result: AnyObject?
        guard AXUIElementCopyAttributeValue(windowElement, attribute, &result) == .Success else {
            return nil
        }
        
        let value = result as! AXValueRef
        guard AXValueGetType(value) == type else {
            return nil
        }
        
        return value
    }
    
    private func setValue(value: AXValueRef, attribute: String) {
        let status = AXUIElementSetAttributeValue(windowElement, attribute, value)

        if status != .Success {
            print("Failed to set \(attribute)=\(value)")
        }
    }
    
    private var position: CGPoint? {
        get {
            guard let positionValue = value(kAXPositionAttribute, type: .CGPoint) else {
                return nil
            }
            
            var position = CGPoint()
            AXValueGetValue(positionValue, .CGPoint, &position)
            
            return position
        }
        
        set {
            var origin = newValue
            guard let value = AXValueCreate(.CGPoint, &origin) else {
                print("Failed to create positionRef")
                return
            }
            
            let positionRef = value.takeRetainedValue()
            setValue(positionRef, attribute: kAXPositionAttribute)
        }
    }
    
    private var size: CGSize? {
        get {
            guard let sizeValue = value(kAXSizeAttribute, type: .CGSize) else {
                return nil
            }
            
            var size = CGSize()
            AXValueGetValue(sizeValue, .CGSize, &size)
            
            return size
        }
        
        set {
            var size = newValue
            guard let value = AXValueCreate(.CGSize, &size) else {
                print("Failed to create sizeRef")
                return
            }
            
            let sizeRef = value.takeRetainedValue()
            setValue(sizeRef, attribute: kAXSizeAttribute)
        }
    }
    
    var frame: CGRect? {
        get {
            guard let position = position, size = size else {
                return nil
            }
            
            return CGRect(origin: CGPoint(x: position.x, y: primaryScreenHeight - size.height - position.y), size: size)
        }
        
        set {
            if let frame = newValue {
                position = CGPoint(x: frame.origin.x, y: primaryScreenHeight - frame.size.height - frame.origin.y)
                size = frame.size
            }
        }
    }
    
    
    func center() {
        if let screen = screen(), size = size {
            let newX = screen.visibleFrame.midX - size.width / 2
            let newY = screen.visibleFrame.midY - size.height / 2
            frame = CGRect(origin: CGPoint(x: newX, y: newY), size: size)
        }
    }
    
    func maximize() {
        if let screen = screen() {
            frame = screen.visibleFrame
        }
    }
    
    func activateWithOptions(options: NSApplicationActivationOptions) {
        app.activateWithOptions(options)
    }
    
    func screen() -> NSScreen? {
        guard let screens = NSScreen.screens(), appFrame = frame else {
            return nil
        }
        
        var result: NSScreen? = nil
        var area: CGFloat = 0

        print("App Frame: \(appFrame)")
        for (index, screen) in screens.enumerate() {
            print("Screen \(index): \(screen.frame)")
            let overlap = screen.frame.intersect(appFrame)
            if overlap.width * overlap.height > area {
                area = overlap.width * overlap.height
                result = screen
            }
        }
        
        return result
    }
    
    var appTitle: String? {
        get {
            guard CFGetTypeID(appElement) == AXUIElementGetTypeID() else {
                return nil
            }
            
            var result: AnyObject?
            guard AXUIElementCopyAttributeValue(appElement, kAXTitleAttribute, &result) == .Success else {
                return nil
            }
            
            return result as? String
        }
    }
    
    var windowTitle: String? {
        get {
            guard CFGetTypeID(windowElement) == AXUIElementGetTypeID() else {
                return nil
            }
            
            var result: AnyObject?
            guard AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute, &result) == .Success else {
                return nil
            }
            
            return result as? String
        }
    }
}