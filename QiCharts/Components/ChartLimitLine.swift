//
//  ChartLimitLine.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics


@objc(ChartLimitLine)
open class ChartLimitLine: ComponentBase
{
    @objc(ChartLimitLabelPosition)
    public enum LabelPosition: Int {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
    
    /// limit / maximum (the y-value or xIndex)
    @objc open var limit = Double(0.0)
    
    private var _lineWidth = CGFloat(2.0)
    @objc open var lineColor = NSUIColor(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    @objc open var lineDashPhase = CGFloat(0.0)
    @objc open var lineDashLengths: [CGFloat]?
    
    @objc open var valueTextColor = NSUIColor.black
    @objc open var valueFont = NSUIFont.systemFont(ofSize: 13.0)
    
    @objc open var drawLabelEnabled = true
    @objc open var label = ""
    @objc open var labelPosition = LabelPosition.rightTop
    
    public override init()
    {
        super.init()
    }
    
    @objc public init(limit: Double)
    {
        super.init()
        self.limit = limit
    }
    
    @objc public init(limit: Double, label: String)
    {
        super.init()
        self.limit = limit
        self.label = label
    }
    
    /// set the line width of the chart (min = 0.2, max = 12); default 2
    @objc open var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
            if newValue < 0.2
            {
                _lineWidth = 0.2
            }
            else if newValue > 12.0
            {
                _lineWidth = 12.0
            }
            else
            {
                _lineWidth = newValue
            }
        }
    }
}
