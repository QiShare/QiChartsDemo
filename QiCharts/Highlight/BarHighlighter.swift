//
//  BarHighlighter.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc(BarChartHighlighter)
open class BarHighlighter: ChartHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard
            let barData = (self.chart as? BarChartView)?.barData,
            let high = super.getHighlight(x: x, y: y)
            else { return nil }
        
        let pos = getValsForTouch(x: x, y: y)

        if let set = barData.getDataSetByIndex(high.dataSetIndex) as? BarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.x),
                                       yValue: Double(pos.y))
        }
        else
        {
            return high
        }
    }
    
    internal override func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }
    
    internal override var data: ChartData?
    {
        return (chart as? BarChartView)?.barData
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// - parameter high: the Highlight to work with looking for stacked values
    /// - parameter set:
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - returns:
    @objc open func getStackedHighlight(high: Highlight,
                                  set: BarChartDataSet,
                                  xValue: Double,
                                  yValue: Double) -> Highlight?
    {
        guard
            let chart = self.chart as? BarLineScatterCandleChartViewBase,
            let entry = set.entryForXValue(xValue, closestToY: yValue) as? BarChartDataEntry
            else { return nil }
        
        // Not stacked
        if entry.yValues == nil
        {
            return high
        }
        
        guard
            let ranges = entry.ranges,
            ranges.count > 0
            else { return nil }

        let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
        let pixel = chart
            .getTransformer(forAxis: set.axisDependency)
            .pixelForValue(x: high.x, y: ranges[stackIndex].to)

        return Highlight(x: entry.x,
                         y: entry.y,
                         xPx: pixel.x,
                         yPx: pixel.y,
                         dataSetIndex: high.dataSetIndex,
                         stackIndex: stackIndex,
                         axis: high.axis)
    }
    
    /// - returns: The index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    /// - parameter entry:
    /// - parameter value:
    /// - returns:
    @objc open func getClosestStackIndex(ranges: [Range]?, value: Double) -> Int
    {
        guard let ranges = ranges else { return 0 }

        var stackIndex = 0
        
        for range in ranges
        {
            if range.contains(value)
            {
                return stackIndex
            }
            else
            {
                stackIndex += 1
            }
        }
        
        let length = max(ranges.count - 1, 0)
        
        return (value > ranges[length].to) ? length : 0
    }
}
