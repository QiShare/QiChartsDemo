//
//  ChartDataEntry.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

open class ChartDataEntry: NSObject
{
    /// the x value
    @objc open var x = Double(0.0)
    
    /// the y value
    @objc open var y = Double(0.0)
    
    /// optional spot for additional data this Entry represents
    @objc open var data: AnyObject?
    
    /// optional icon image
    @objc open var icon: NSUIImage?
    
    public required override init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    @objc public init(x: Double, y: Double)
    {
        super.init()
        self.y = y
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, data: AnyObject?)
    {
        super.init()
        self.x = x
        self.y = y
        self.data = data
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?)
    {
        super.init()
        self.y = y
        self.x = x
        self.icon = icon
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init()
        self.y = y
        self.x = x
        self.data = data
        self.icon = icon
    }
        
    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    // MARK: NSCopying
    
    @objc open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = type(of: self).init()
        
        copy.x = x
        copy.y = y
        copy.data = data
        copy.icon = icon
        
        return copy
    }
}

// MARK: Equatable
extension ChartDataEntry/*: Equatable*/ {
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChartDataEntry else { return false }

        if self === object
        {
            return true
        }

        return ((data == nil && object.data == nil) || (data?.isEqual(object.data) ?? false))
            && y == object.y
            && x == object.x
    }
}
