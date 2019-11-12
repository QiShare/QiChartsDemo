//
//  Description.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

@objc(ChartDescription)
open class Description: ComponentBase
{
    public override init()
    {
        #if os(tvOS)
            // 23 is the smallest recommended font size on the TV
            font = NSUIFont.systemFont(ofSize: 23)
        #elseif os(OSX)
            font = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)
        #else
            font = NSUIFont.systemFont(ofSize: 8.0)
        #endif
        
        super.init()
    }
    
    /// The text to be shown as the description.
    @objc open var text: String? = "Description Label"
    
    /// Custom position for the description text in pixels on the screen.
    open var position: CGPoint? = nil
    
    /// The text alignment of the description text. Default RIGHT.
    @objc open var textAlign: NSTextAlignment = NSTextAlignment.right
    
    /// Font object used for drawing the description text.
    @objc open var font: NSUIFont
    
    /// Text color used for drawing the description text
    @objc open var textColor = NSUIColor.black
}
