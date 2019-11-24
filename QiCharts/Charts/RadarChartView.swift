//
//  RadarChartView.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class RadarChartView: PieRadarChartViewBase
{
    /// 从中心向外轴线 的宽度
    @objc open var webLineWidth = CGFloat(1.5)
    
    /// 从中心向外轴线之间线 的宽度
    @objc open var innerWebLineWidth = CGFloat(0.75)
    
    /// “轴线”的颜色
    @objc open var webColor = NSUIColor(red: 122/255.0, green: 122/255.0, blue: 122.0/255.0, alpha: 1.0)
    
    /// “轴线”之间线的颜色
    @objc open var innerWebColor = NSUIColor(red: 122/255.0, green: 122/255.0, blue: 122.0/255.0, alpha: 1.0)
    
    /// 整个网格线的透明度
    @objc open var webAlpha: CGFloat = 150.0 / 255.0
    
    /// 是否绘制网格
    @objc open var drawWeb = true
    
    /// the object reprsenting the y-axis labels
    private var _yAxis: YAxis!
    
    internal var _yAxisRenderer: YAxisRendererRadarChart!
    internal var _xAxisRenderer: XAxisRendererRadarChart!
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _yAxis = YAxis(position: .left)
        
        renderer = RadarChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        _yAxisRenderer = YAxisRendererRadarChart(viewPortHandler: _viewPortHandler, yAxis: _yAxis, chart: self)
        _xAxisRenderer = XAxisRendererRadarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, chart: self)
        
        self.highlighter = RadarHighlighter(chart: self)
    }

    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        guard let data = _data else { return }
        
        _yAxis.calculate(min: data.getYMin(axis: .left), max: data.getYMax(axis: .left))
        _xAxis.calculate(min: 0.0, max: Double(data.maxEntryCountSet?.entryCount ?? 0))
    }
    
    open override func notifyDataSetChanged()
    {
        calcMinMax()

        _yAxisRenderer?.computeAxis(min: _yAxis._axisMinimum, max: _yAxis._axisMaximum, inverted: _yAxis.isInverted)
        _xAxisRenderer?.computeAxis(min: _xAxis._axisMinimum, max: _xAxis._axisMaximum, inverted: false)
        
        if let data = _data,
            let legend = _legend,
            !legend.isLegendCustom
        {
            legendRenderer?.computeLegend(data: data)
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)

        guard data != nil, let renderer = renderer else { return }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        if _xAxis.isEnabled
        {
            _xAxisRenderer.computeAxis(min: _xAxis._axisMinimum, max: _xAxis._axisMaximum, inverted: false)
        }
        
        _xAxisRenderer?.renderAxisLabels(context: context)
        
        if drawWeb
        {
            renderer.drawExtras(context: context)
        }
        
        if _yAxis.isEnabled && _yAxis.drawLimitLinesBehindDataEnabled
        {
            _yAxisRenderer.renderLimitLines(context: context)
        }

        renderer.drawData(context: context)

        if _highlights.count > 0
        {
            renderer.drawHighlighted(context: context, indices: _highlights)
        }
        
        if _yAxis.isEnabled && !_yAxis.drawLimitLinesBehindDataEnabled
        {
            _yAxisRenderer.renderLimitLines(context: context)
        }
        
        _yAxisRenderer.renderAxisLabels(context: context)

        renderer.drawValues(context: context)

        legendRenderer.renderLegend(context: context)

        drawDescription(context: context)

        drawMarkers(context: context)
    }

    /// - returns: The factor that is needed to transform values into pixels.
    @objc open var factor: CGFloat
    {
        let content = _viewPortHandler.contentRect
        return min(content.width / 2.0, content.height / 2.0)
                / CGFloat(_yAxis.axisRange)
    }

    /// - returns: The angle that each slice in the radar chart occupies.
    @objc open var sliceAngle: CGFloat
    {
        return 360.0 / CGFloat(_data?.maxEntryCountSet?.entryCount ?? 0)
    }

    open override func indexForAngle(_ angle: CGFloat) -> Int
    {
        // take the current angle of the chart into consideration
        let a = (angle - self.rotationAngle).normalizedAngle
        
        let sliceAngle = self.sliceAngle
        
        let max = _data?.maxEntryCountSet?.entryCount ?? 0
        
        var index = 0
        
        for i in 0..<max
        {
            let referenceAngle = sliceAngle * CGFloat(i + 1) - sliceAngle / 2.0
            
            if referenceAngle > a
            {
                index = i
                break
            }
        }
        
        return index
    }

    /// - returns: The object that represents all y-labels of the RadarChart.
    @objc open var yAxis: YAxis
    {
        return _yAxis
    }

    internal override var requiredLegendOffset: CGFloat
    {
        return _legend.font.pointSize * 4.0
    }

    internal override var requiredBaseOffset: CGFloat
    {
        return _xAxis.isEnabled && _xAxis.drawLabelsEnabled ? _xAxis.labelRotatedWidth : 10.0
    }

    open override var radius: CGFloat
    {
        let content = _viewPortHandler.contentRect
        return min(content.width / 2.0, content.height / 2.0)
    }

    /// - returns: The maximum value this chart can display on it's y-axis.
    open override var chartYMax: Double { return _yAxis._axisMaximum }
    
    /// - returns: The minimum value this chart can display on it's y-axis.
    open override var chartYMin: Double { return _yAxis._axisMinimum }
    
    /// - returns: The range of y-values this chart can display.
    @objc open var yRange: Double { return _yAxis.axisRange }
}
