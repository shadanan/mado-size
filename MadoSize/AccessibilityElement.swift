//
//  AccessibilityElement.swift
//  MadoSize
//
//  Created by Shad Sharma on 7/3/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa
import Foundation

class AccessibilityElement {
    let underlyingElement: AXUIElementRef
    
    static func frontmostApplicationElement() -> AccessibilityElement? {
        guard let frontmostApplication = NSWorkspace.sharedWorkspace().frontmostApplication else {
            print("Failed to get the application that currently has focus.")
            return nil
        }
        
        let underlyingElement = AXUIElementCreateApplication(frontmostApplication.processIdentifier).takeRetainedValue()
        return AccessibilityElement(underlyingElement: underlyingElement)
    }
    
    static func frontmostWindowElement() -> AccessibilityElement? {
        guard let appElement = AccessibilityElement.frontmostApplicationElement() else {
            return nil
        }
        
        guard let windowElement = appElement.elementWithAttribute(kAXFocusedWindowAttribute) else {
            return nil
        }
        
        return windowElement
    }
    
    init(underlyingElement: AXUIElementRef) {
        self.underlyingElement = underlyingElement
    }
    
    private func elementWithAttribute(attribute: String) -> AccessibilityElement? {
        var result: AnyObject?
        
        guard AXUIElementCopyAttributeValue(underlyingElement, attribute, &result) == .Success else {
            print("Failed to get element with attribute: \(attribute)")
            return nil
        }
        
        let focusedUnderlyingElement = result as! AXUIElementRef
        return AccessibilityElement(underlyingElement: focusedUnderlyingElement)
    }
    
    private func value(attribute: String, type: AXValueType) -> AXValueRef? {
        guard CFGetTypeID(underlyingElement) == AXUIElementGetTypeID() else {
            return nil
        }
        
        var result: AnyObject?
        guard AXUIElementCopyAttributeValue(underlyingElement, attribute, &result) == .Success else {
            return nil
        }
        
        let value = result as! AXValueRef
        guard AXValueGetType(value) == type else {
            return nil
        }
        
        return value
    }
    
    private func setValue(value: AXValueRef, attribute: String) {
        let status = AXUIElementSetAttributeValue(underlyingElement, attribute, value)

        if status != .Success {
            print("Failed to set \(attribute)=\(value)")
        }
    }
    
    func position() -> CGPoint? {
        guard let positionValue = value(kAXPositionAttribute, type: .CGPoint) else {
            return nil
        }
        
        var position = CGPoint()
        AXValueGetValue(positionValue, .CGPoint, &position)
        
        return position
    }
    
    func size() -> CGSize? {
        guard let sizeValue = value(kAXSizeAttribute, type: .CGSize) else {
            return nil
        }
        
        var size = CGSize()
        AXValueGetValue(sizeValue, .CGSize, &size)
        
        return size
    }
    
    func title() -> String? {
        guard CFGetTypeID(underlyingElement) == AXUIElementGetTypeID() else {
            return nil
        }
        
        var result: AnyObject?
        guard AXUIElementCopyAttributeValue(underlyingElement, kAXTitleAttribute, &result) == .Success else {
            return nil
        }
        
        guard let value = result as? String else {
            return nil
        }
        
        return value
    }
    
    func setPosition(origin: CGPoint) {
        var origin = origin
        guard let value = AXValueCreate(.CGPoint, &origin) else {
            print("Failed to create positionRef")
            return
        }
        
        let positionRef = value.takeRetainedValue()
        setValue(positionRef, attribute: kAXPositionAttribute)
    }
    
    func setSize(size: CGSize) {
        var size = size
        guard let value = AXValueCreate(.CGSize, &size) else {
            print("Failed to create sizeRef")
            return
        }

        let sizeRef = value.takeRetainedValue()
        setValue(sizeRef, attribute: kAXSizeAttribute)
    }
}