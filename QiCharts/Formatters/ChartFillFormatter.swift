//
//  DefaultFillFormatter.swift
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

/// Default formatter that calculates the position of the filled line.
@objc(ChartFillFormatter)
open class ChartFillFormatter: NSObject
{
    public typealias Block = (_ dataSet: LineChartDataSet, _ dataProvider: LineChartView) -> CGFloat
    
    @objc open var block: Block?
    
    public override init() { }
    
    @objc public init(block: @escaping Block)
    {
        self.block = block
    }
    
    @objc public static func with(block: @escaping Block) -> ChartFillFormatter?
    {
        return ChartFillFormatter(block: block)
    }
    
    open func getFillLinePosition(dataSet: LineChartDataSet, chartView: LineChartView) -> CGFloat
    {
        guard block == nil else { return block!(dataSet, chartView) }
        var fillMin: CGFloat = 0.0

        if dataSet.yMax > 0.0 && dataSet.yMin < 0.0
        {
            fillMin = 0.0
        }
        else if let data = chartView.data
        {
            let max = data.yMax > 0.0 ? 0.0 : chartView.chartYMax
            let min = data.yMin < 0.0 ? 0.0 : chartView.chartYMin

            fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max)
        }

        return fillMin
    }
}
