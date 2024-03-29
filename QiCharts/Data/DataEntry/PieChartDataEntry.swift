//
//  PieChartDataEntry.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class PieChartDataEntry: ChartDataEntry
{
    public required init()
    {
        super.init()
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    @objc public convenience init(value: Double, label: String?)
    {
        self.init(value: value, label: label, icon: nil, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, label: String?, data: AnyObject?)
    {
        self.init(value: value, label: label, icon: nil, data: data)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter icon: icon image
    @objc public convenience init(value: Double, label: String?, icon: NSUIImage?)
    {
        self.init(value: value, label: label, icon: icon, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    @objc public init(value: Double, label: String?, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: 0.0, y: value, icon: icon, data: data)
        
        self.label = label
    }
    
    /// - parameter value: The value on the y-axis
    @objc public convenience init(value: Double)
    {
        self.init(value: value, label: nil, icon: nil, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, data: AnyObject?)
    {
        self.init(value: value, label: nil, icon: nil, data: data)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    @objc public convenience init(value: Double, icon: NSUIImage?)
    {
        self.init(value: value, label: nil, icon: icon, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, icon: NSUIImage?, data: AnyObject?)
    {
        self.init(value: value, label: nil, icon: icon, data: data)
    }
    
    // MARK: Data property accessors
    
    @objc open var label: String?
    
    @objc open var value: Double
    {
        get { return y }
        set { y = newValue }
    }
        
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! PieChartDataEntry
        copy.label = label
        return copy
    }
}
