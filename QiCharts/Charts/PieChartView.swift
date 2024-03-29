//
//  PieChartView.swift
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

open class PieChartView: PieRadarChartViewBase
{
    /// 饼图绘制区域的rect
    private var _circleBox = CGRect()
    
    /// 保存每个“扇形”角度的数组
    private var _drawAngles = [CGFloat]()
    
    /// 相应entry的“扇形”末尾所对应的角度数组
    private var _absoluteAngles = [CGFloat]()
    
    /// 是否绘制空心区域，即饼图是否为圆环型
    private var _drawHoleEnabled = true
    
    /// 空心区域的颜色
    private var _holeColor: NSUIColor? = NSUIColor.white
    
    /// 是否绘制Entry的value标签
    private var _drawEntryLabelsEnabled = true
    
    /// 绘制Entry的value标签的颜色
    private var _entryLabelColor: NSUIColor? = NSUIColor.white
    
    /// 绘制Entry的value标签的font
    private var _entryLabelFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 13.0)
    
    /// 绘制的Entry的value是否以百分比显示（需要配合data中的formattor使用！）
    private var _usePercentValuesEnabled = false
    
    /// 是否在hole中心绘制描述文字
    private var _drawCenterTextEnabled = true
    
    /// 有hole时，在hole中心绘制描述文字的内容
    private var _centerAttributedText: NSAttributedString?
    
    /// hole中心绘制文字的偏移量（常在半圆饼图时有需要）
    private var _centerTextOffset: CGPoint = CGPoint()
    
    /// 空心半径对于pie半径的占比
    private var _holeRadiusPercent = CGFloat(0.5)
    
    /// 半透明圆的对于pie半径的占比
    private var _transparentCircleRadiusPercent = CGFloat(0.55)
    
    /// /// 半透明圆的颜色
    private var _transparentCircleColor: NSUIColor? = NSUIColor(white: 1.0, alpha: 105.0/255.0)
    
    private var _centerTextRadiusPercent: CGFloat = 0.75
    
    /// 饼图的最大角度
    private var _maxAngle: CGFloat = 360.0

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
        
        renderer = PieChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxis = nil
        
        self.highlighter = PieHighlighter(chart: self)
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if _data === nil
        {
            return
        }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext, let renderer = renderer else
        {
            return
        }
        
        renderer.drawData(context: context)
        
        if (_highlights.count > 0)
        {
            renderer.drawHighlighted(context: context, indices: highlights)
        }
        
        renderer.drawExtras(context: context)
        
        renderer.drawValues(context: context)
        
        legendRenderer.renderLegend(context: context)
        
        drawDescription(context: context)
        
        drawMarkers(context: context)
    }
    
    internal override func calculateOffsets()
    {
        super.calculateOffsets()
        
        // prevent nullpointer when no data set
        if _data === nil
        {
            return
        }
        
        // diameter为图表直径（在基类中定义）
        let radius = diameter / 2.0
        
        let c = self.centerOffsets
        
        let shift = (data as? PieChartData)?.dataSet?.selectionShift ?? 0.0
        
        // create the circle box that will contain the pie-chart (the bounds of the pie-chart)
        _circleBox.origin.x = (c.x - radius) + shift
        _circleBox.origin.y = (c.y - radius) + shift
        _circleBox.size.width = diameter - shift * 2.0
        _circleBox.size.height = diameter - shift * 2.0
    }
    
    internal override func calcMinMax()
    {
        calcAngles()
    }
    
    open override func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        let center = self.centerCircleBox
        var r = self.radius
        
        var off = r / 10.0 * 3.6
        
        if self.isDrawHoleEnabled
        {
            off = (r - (r * self.holeRadiusPercent)) / 2.0
        }
        
        r -= off // offset to keep things inside the chart
        
        let rotationAngle = self.rotationAngle
        
        let entryIndex = Int(highlight.x)
        
        // offset needed to center the drawn text in the slice
        let offset = drawAngles[entryIndex] / 2.0
        
        // calculate the text position
        let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.x)
        let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.y)
        
        return CGPoint(x: x, y: y)
    }
    
    /// calculates the needed angles for the chart slices
    private func calcAngles()
    {
        _drawAngles = [CGFloat]()
        _absoluteAngles = [CGFloat]()
        
        guard let data = _data else { return }

        let entryCount = data.entryCount
        
        _drawAngles.reserveCapacity(entryCount)
        _absoluteAngles.reserveCapacity(entryCount)
        
        let yValueSum = (_data as! PieChartData).yValueSum
        
        let dataSets = data.dataSets

        var cnt = 0

        for i in 0 ..< data.dataSetCount
        {
            let set = dataSets[i]
            let entryCount = set.entryCount

            for j in 0 ..< entryCount
            {
                guard let e = set.entryForIndex(j) else { continue }
                
                _drawAngles.append(calcAngle(value: abs(e.y), yValueSum: yValueSum))

                if cnt == 0
                {
                    _absoluteAngles.append(_drawAngles[cnt])
                }
                else
                {
                    _absoluteAngles.append(_absoluteAngles[cnt - 1] + _drawAngles[cnt])
                }

                cnt += 1
            }
        }
    }
    
    /// Checks if the given index is set to be highlighted.
    @objc open func needsHighlight(index: Int) -> Bool
    {
        // no highlight
        if !(_highlights.count > 0)
        {
            return false
        }
        
        for i in 0 ..< highlights.count
        {
            // check if the xvalue for the given dataset needs highlight
            if Int(_highlights[i].x) == index
            {
                return true
            }
        }
        
        return false
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(_ value: Double) -> CGFloat
    {
        return calcAngle(value: value, yValueSum: (_data as! PieChartData).yValueSum)
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(value: Double, yValueSum: Double) -> CGFloat
    {
        return CGFloat(value) / CGFloat(yValueSum) * _maxAngle
    }
    
    /// This will throw an exception, PieChart has no XAxis object.
    open override var xAxis: XAxis
    {
        fatalError("PieChart has no XAxis")
    }
    
    open override func indexForAngle(_ angle: CGFloat) -> Int
    {
        // take the current angle of the chart into consideration
        let a = (angle - self.rotationAngle).normalizedAngle
        for i in 0 ..< _absoluteAngles.count
        {
            if _absoluteAngles[i] > a
            {
                return i
            }
        }
        
        return -1 // return -1 if no index found
    }
    
    /// - returns: The index of the DataSet this x-index belongs to.
    @objc open func dataSetIndexForIndex(_ xValue: Double) -> Int
    {
        let dataSets = _data?.dataSets ?? []
        
        for i in 0 ..< dataSets.count
        {
            if (dataSets[i].entryForXValue(xValue, closestToY: Double.nan) !== nil)
            {
                return i
            }
        }
        
        return -1
    }
    
    /// - returns: An integer array of all the different angles the chart slices
    /// have the angles in the returned array determine how much space (of 360°)
    /// each slice takes
    @objc open var drawAngles: [CGFloat]
    {
        return _drawAngles
    }

    /// - returns: The absolute angles of the different chart slices (where the
    /// slices end)
    @objc open var absoluteAngles: [CGFloat]
    {
        return _absoluteAngles
    }
    
    /// The color for the hole that is drawn in the center of the PieChart (if enabled).
    /// 
    /// - note: Use holeTransparent with holeColor = nil to make the hole transparent.*
    @objc open var holeColor: NSUIColor?
    {
        get
        {
            return _holeColor
        }
        set
        {
            _holeColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    @objc open var drawHoleEnabled: Bool
    {
        get
        {
            return _drawHoleEnabled
        }
        set
        {
            _drawHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    @objc open var isDrawHoleEnabled: Bool
    {
        get
        {
            return drawHoleEnabled
        }
    }
    
    /// the text that is displayed in the center of the pie-chart
    @objc open var centerText: String?
    {
        get
        {
            return self.centerAttributedText?.string
        }
        set
        {
            var attrString: NSMutableAttributedString?
            if newValue == nil
            {
                attrString = nil
            }
            else
            {
                #if os(OSX)
                    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    paragraphStyle.lineBreakMode = NSParagraphStyle.LineBreakMode.byTruncatingTail
                #else
                    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                #endif
                paragraphStyle.alignment = .center
                
                attrString = NSMutableAttributedString(string: newValue!)
                attrString?.setAttributes([
                    NSAttributedString.Key.foregroundColor: NSUIColor.black,
                    NSAttributedString.Key.font: NSUIFont.systemFont(ofSize: 12.0),
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ], range: NSMakeRange(0, attrString!.length))
            }
            self.centerAttributedText = attrString
        }
    }
    
    /// the text that is displayed in the center of the pie-chart
    @objc open var centerAttributedText: NSAttributedString?
    {
        get
        {
            return _centerAttributedText
        }
        set
        {
            _centerAttributedText = newValue
            setNeedsDisplay()
        }
    }
    
    /// Sets the offset the center text should have from it's original position in dp. Default x = 0, y = 0
    @objc open var centerTextOffset: CGPoint
    {
        get
        {
            return _centerTextOffset
        }
        set
        {
            _centerTextOffset = newValue
            setNeedsDisplay()
        }
    }
    
    /// `true` if drawing the center text is enabled
    @objc open var drawCenterTextEnabled: Bool
    {
        get
        {
            return _drawCenterTextEnabled
        }
        set
        {
            _drawCenterTextEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing the center text is enabled
    @objc open var isDrawCenterTextEnabled: Bool
    {
        get
        {
            return drawCenterTextEnabled
        }
    }
    
    internal override var requiredLegendOffset: CGFloat
    {
        return _legend.font.pointSize * 2.0
    }
    
    internal override var requiredBaseOffset: CGFloat
    {
        return 0.0
    }
    
    open override var radius: CGFloat
    {
        return _circleBox.width / 2.0
    }
    
    /// - returns: The circlebox, the boundingbox of the pie-chart slices
    @objc open var circleBox: CGRect
    {
        return _circleBox
    }
    
    /// - returns: The center of the circlebox
    @objc open var centerCircleBox: CGPoint
    {
        return CGPoint(x: _circleBox.midX, y: _circleBox.midY)
    }
    
    /// the radius of the hole in the center of the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.5 (50%) (half the pie)
    @objc open var holeRadiusPercent: CGFloat
    {
        get
        {
            return _holeRadiusPercent
        }
        set
        {
            _holeRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// The color that the transparent-circle should have.
    ///
    /// **default**: `nil`
    @objc open var transparentCircleColor: NSUIColor?
    {
        get
        {
            return _transparentCircleColor
        }
        set
        {
            _transparentCircleColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// the radius of the transparent circle that is drawn next to the hole in the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.55 (55%) -> means 5% larger than the center-hole by default
    @objc open var transparentCircleRadiusPercent: CGFloat
    {
        get
        {
            return _transparentCircleRadiusPercent
        }
        set
        {
            _transparentCircleRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
        
    /// The color the entry labels are drawn with.
    @objc open var entryLabelColor: NSUIColor?
    {
        get { return _entryLabelColor }
        set
        {
            _entryLabelColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// The font the entry labels are drawn with.
    @objc open var entryLabelFont: NSUIFont?
    {
        get { return _entryLabelFont }
        set
        {
            _entryLabelFont = newValue
            setNeedsDisplay()
        }
    }
    
    /// Set this to true to draw the enrty labels into the pie slices
    @objc open var drawEntryLabelsEnabled: Bool
    {
        get
        {
            return _drawEntryLabelsEnabled
        }
        set
        {
            _drawEntryLabelsEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing entry labels is enabled, `false` ifnot
    @objc open var isDrawEntryLabelsEnabled: Bool
    {
        get
        {
            return drawEntryLabelsEnabled
        }
    }
    
    @objc open var usePercentValuesEnabled: Bool
    {
        get
        {
            return _usePercentValuesEnabled
        }
        set
        {
            _usePercentValuesEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing x-values is enabled, `false` ifnot
    @objc open var isUsePercentValuesEnabled: Bool
    {
        get
        {
            return usePercentValuesEnabled
        }
    }
    
    /// the rectangular radius of the bounding box for the center text, as a percentage of the pie hole
    @objc open var centerTextRadiusPercent: CGFloat
    {
        get
        {
            return _centerTextRadiusPercent
        }
        set
        {
            _centerTextRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// The max angle that is used for calculating the pie-circle.
    /// 360 means it's a full pie-chart, 180 results in a half-pie-chart.
    /// **default**: 360.0
    @objc open var maxAngle: CGFloat
    {
        get
        {
            return _maxAngle
        }
        set
        {
            _maxAngle = newValue
            
            if _maxAngle > 360.0
            {
                _maxAngle = 360.0
            }
            
            if _maxAngle < 90.0
            {
                _maxAngle = 90.0
            }
        }
    }
}
