//
//  RadarChartDataEntry.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class RadarChartDataEntry: ChartDataEntry
{
    public required init()
    {
        super.init()
    }
    
    /// - parameter value: The value on the y-axis.
    /// - parameter data: Spot for additional data this Entry represents.
    @objc public init(value: Double, data: AnyObject?)
    {
        super.init(x: 0.0, y: value, data: data)
    }
    
    /// - parameter value: The value on the y-axis.
    @objc public convenience init(value: Double)
    {
        self.init(value: value, data: nil)
    }
    
    // MARK: Data property accessors
    
    @objc open var value: Double
    {
        get { return y }
        set { y = newValue }
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RadarChartDataEntry
        
        return copy
    }
}
