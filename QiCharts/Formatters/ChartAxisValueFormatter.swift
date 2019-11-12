//
//  DefaultAxisValueFormatter.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

@objc(ChartAxisValueFormatter)
open class ChartAxisValueFormatter: NSObject
{
    public typealias Block = (
        _ value: Double,
        _ axis: AxisBase?) -> String
    
    @objc open var block: Block?
    
    @objc open var hasAutoDecimals: Bool = false
    
    private var _formatter: NumberFormatter?
    @objc open var formatter: NumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }

    // TODO: Documentation. Especially the nil case
    private var _decimals: Int?
    open var decimals: Int?
    {
        get { return _decimals }
        set
        {
            _decimals = newValue
            
            if let digits = newValue
            {
                self.formatter?.minimumFractionDigits = digits
                self.formatter?.maximumFractionDigits = digits
                self.formatter?.usesGroupingSeparator = true
            }
        }
    }
    
    public override init()
    {
        super.init()
        
        self.formatter = NumberFormatter()
        hasAutoDecimals = true
    }
    
    @objc public init(formatter: NumberFormatter)
    {
        super.init()
        
        self.formatter = formatter
    }
    
    @objc public init(decimals: Int)
    {
        super.init()
        
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    @objc public init(block: @escaping Block)
    {
        super.init()
        
        self.block = block
    }
    
    @objc public static func with(block: @escaping Block) -> ChartAxisValueFormatter?
    {
        return ChartAxisValueFormatter(block: block)
    }
    
    open func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        if let block = block {
            return block(value, axis)
        } else {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
}
