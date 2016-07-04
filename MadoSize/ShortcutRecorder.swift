//
//  ShortcutRecorder.swift
//  MadoSize
//
//  Created by Shad Sharma on 7/3/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa
import Foundation

class ShortcutRecorder: NSView {
    override func keyDown(theEvent: NSEvent) {
        Swift.print(theEvent)
    }
}
