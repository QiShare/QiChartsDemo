//
//  BarChartView.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics


open class BarChartView: BarLineScatterCandleChartViewBase
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = BarChartRenderer(chartView: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        self.highlighter = BarHighlighter(chart: self)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    internal override func calcMinMax()
    {
        guard let data = self.data as? BarChartData
            else { return }
        
        if fitBars
        {
            _xAxis.calculate(
                min: data.xMin - data.barWidth / 2.0,
                max: data.xMax + data.barWidth / 2.0)
        }
        else
        {
            _xAxis.calculate(min: data.xMin, max: data.xMax)
        }
        
        // calculate axis range (min / max) according to provided data
        leftAxis.calculate(
            min: data.getYMin(axis: .left),
            max: data.getYMax(axis: .left))
        rightAxis.calculate(
            min: data.getYMin(axis: .right),
            max: data.getYMax(axis: .right))
    }
    
    /// 根据点击的像素点获取对应的Highlight（x-index and DataSet index）
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        guard let highlight = self.highlighter?.getHighlight(x: pt.x, y: pt.y)
            else { return nil }
        
        if !highlightFullBarEnabled { return highlight }
        
        return Highlight(
            x: highlight.x, y: highlight.y,
            xPx: highlight.xPx, yPx: highlight.yPx,
            dataIndex: highlight.dataIndex,
            dataSetIndex: highlight.dataSetIndex,
            stackIndex: -1,
            axis: highlight.axis)
    }
        
    @objc open func getBarBounds(entry e: BarChartDataEntry) -> CGRect
    {
        guard let
            data = _data as? BarChartData,
            let set = data.getDataSetForEntry(e) as? BarChartDataSet
            else { return CGRect.null }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let left = x - barWidth / 2.0
        let right = x + barWidth / 2.0
        let top = y >= 0.0 ? y : 0.0
        let bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(forAxis: set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    /// 对组柱状图数据进行分组
    ///
    /// - parameter fromX: x轴上的起点
    /// - parameter groupSpace: 组间隙 0～0.99
    /// - parameter barSpace: bar间隙 0～0.99
    @objc open func groupBars(fromX: Double, groupSpace: Double, barSpace: Double)
    {
        guard let barData = self.barData
            else
        {
            Swift.print("You need to set data for the chart before grouping bars.", terminator: "\n")
            return
        }
        
        barData.groupBars(fromX: fromX, groupSpace: groupSpace, barSpace: barSpace)
        notifyDataSetChanged()
    }
    
    // MARK: Accessors
    
    /// 将Bar宽度的一半添加到x轴的每一侧，以允许条形码的条带充分显示。
    @objc open var fitBars = true
    
    /// bar堆叠时，选中时是否都高亮
    @objc open var highlightFullBarEnabled: Bool = false
    
    // MARK: - BarChartDataProvider
    
    open var barData: BarChartData? { return _data as? BarChartData }
}
