//
//  ChartHighlighter.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class ChartHighlighter : NSObject
{
    /// instance of the data-provider
    @objc open weak var chart: ChartViewBase?
    
    @objc public init(chart: ChartViewBase)
    {
        self.chart = chart
    }
    
    open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        let point: CGPoint = getValsForTouch(x: x, y: y)
        let xVal = Double(point.x)
        return getHighlight(xValue: xVal, x: x, y: y)
    }
    
    /// - returns: The corresponding x-pos for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    @objc open func getValsForTouch(x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart as? BarLineScatterCandleChartViewBase else { return .zero }
        
        // take any transformer to determine the values
        return chart.getTransformer(forAxis: .left).valueForTouchPoint(x: x, y: y)
    }
    
    /// - returns: The corresponding ChartHighlight for a given x-value and xy-touch position in pixels.
    /// - parameter xValue:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    @objc open func getHighlight(xValue xVal: Double, x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let chart = chart else { return nil }
        
        let closestValues = getHighlights(xValue: xVal, x: x, y: y)
        guard !closestValues.isEmpty else { return nil }
        
        let leftAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .left)
        let rightAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .right)
        
        let axis: YAxis.AxisDependency = leftAxisMinDist < rightAxisMinDist ? .left : .right
        
        let detail = closestSelectionDetailByPixel(closestValues: closestValues, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    /// - returns: A list of Highlight objects representing the entries closest to the given xVal.
    /// The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
    /// - parameter xValue: the transformed x-value of the x-touch position
    /// - parameter x: touch position
    /// - parameter y: touch position
    /// - returns:
    @objc open func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight]
    {
        var highlights = [Highlight]()
        
        guard let data = self.data else { return highlights }
        
        for i in 0 ..< data.dataSetCount
        {
            guard
                let dataSet = data.getDataSetByIndex(i),
                dataSet.highlightEnabled      // don't include datasets that cannot be highlighted
                else { continue }
            

            // extract all y-values from all DataSets at the given x-value.
            // some datasets (i.e bubble charts) make sense to have multiple values for an x-value. We'll have to find a way to handle that later on. It's more complicated now when x-indices are floating point.
            highlights.append(contentsOf: buildHighlights(dataSet: dataSet, dataSetIndex: i, xValue: xValue, rounding: .closest))
        }
        
        return highlights
    }
    
    /// - returns: An array of `Highlight` objects corresponding to the selected xValue and dataSetIndex.
    internal func buildHighlights(
        dataSet set: ChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> [Highlight]
    {
        var highlights = [Highlight]()
        
        guard let chart = self.chart as? BarLineScatterCandleChartViewBase else { return highlights }
        
        var entries = set.entriesForXValue(xValue)
        if entries.count == 0, let closest = set.entryForXValue(xValue, closestToY: .nan, rounding: rounding)
        {
            // Try to find closest x-value and take all entries for that x-value
            entries = set.entriesForXValue(closest.x)
        }
        
        for e in entries
        {
            let px = chart.getTransformer(forAxis: set.axisDependency).pixelForValue(x: e.x, y: e.y)

            let highlight = Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency)
            highlights.append(highlight)
        }
        
        return highlights
    }

    // - MARK: - Utilities
    
    /// - returns: The `ChartHighlight` of the closest value on the x-y cartesian axes
    internal func closestSelectionDetailByPixel(
        closestValues: [Highlight],
        x: CGFloat,
        y: CGFloat,
        axis: YAxis.AxisDependency?,
        minSelectionDistance: CGFloat) -> Highlight?
    {
        var distance = minSelectionDistance
        var closest: Highlight?
        
        for high in closestValues
        {
            if axis == nil || high.axis == axis
            {
                let cDistance = getDistance(x1: x, y1: y, x2: high.xPx, y2: high.yPx)

                if cDistance < distance
                {
                    closest = high
                    distance = cDistance
                }
            }
        }
        
        return closest
    }
    
    /// - returns: The minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal func getMinimumDistance(
        closestValues: [Highlight],
        y: CGFloat,
        axis: YAxis.AxisDependency) -> CGFloat
    {
        var distance = CGFloat.greatestFiniteMagnitude
        
        for high in closestValues
        {
            if high.axis == axis
            {
                let tempDistance = abs(getHighlightPos(high: high) - y)
                if tempDistance < distance
                {
                    distance = tempDistance
                }
            }
        }
        
        return distance
    }
    
    internal func getHighlightPos(high: Highlight) -> CGFloat
    {
        return high.yPx
    }
    
    internal func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return hypot(x1 - x2, y1 - y2)
    }
    
    internal var data: ChartData?
    {
        return chart?.data
    }
}
