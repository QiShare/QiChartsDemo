//
//  Range.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

@objc(ChartRange)
open class Range: NSObject
{
    @objc open var from: Double
    @objc open var to: Double
    
    @objc public init(from: Double, to: Double)
    {
        self.from = from
        self.to = to
        
        super.init()
    }

    /// - returns: `true` if this range contains (if the value is in between) the given value, `false` ifnot.
    /// - parameter value:
    @objc open func contains(_ value: Double) -> Bool
    {
        if value > from && value <= to
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc open func isLarger(_ value: Double) -> Bool
    {
        return value > to
    }
    
    @objc open func isSmaller(_ value: Double) -> Bool
    {
        return value < from
    }
}
