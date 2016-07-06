//
//  SetDimensions.swift
//  MadoSize
//
//  Created by Shad Sharma on 7/5/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa
import Foundation

class SetDimensionsController: NSWindowController {
    private var initX: Int = 0
    private var initY: Int = 0
    private var initW: Int = 0
    private var initH: Int = 0
    
    @IBOutlet weak var centered: NSButton!
    @IBOutlet weak var xPos: NSTextField!
    @IBOutlet weak var yPos: NSTextField!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var height: NSTextField!
    
    convenience init(position: CGPoint, size: CGSize) {
        self.init(windowNibName: "SetDimensions")
        initX = lroundf(Float(position.x))
        initY = lroundf(Float(position.y))
        initW = lroundf(Float(size.width))
        initH = lroundf(Float(size.height))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xPos.integerValue = initX
        yPos.integerValue = initY
        width.integerValue = initW
        height.integerValue = initH
    }
    
    func position() -> CGPoint {
        return CGPoint(x: xPos.integerValue, y: yPos.integerValue)
    }
    
    func size() -> CGSize {
        return CGSize(width: width.integerValue, height: height.integerValue)
    }
    
    @IBAction func buttonAction(sender: NSButton) {
        NSApp.stopModalWithCode(sender.tag)

        if let window = window {
            window.orderOut(nil)
        }
    }
}