//
//  ChartViewBase.swift
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

@objc
public protocol ChartViewDelegate
{
    /// 选中一个DataEntry
    @objc optional func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    /// 未选中任何DataEntry
    @objc optional func chartValueNothingSelected(_ chartView: ChartViewBase)
    /// 通过夹点缩放手势缩放图表时调用
    @objc optional func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    /// 通过拖动手势 移动/转换 图表时回调
    @objc optional func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)
}

open class ChartViewBase: NSUIView, AnimatorDelegate
{
    // MARK: - 属性
    
    /// x轴
    internal var _xAxis: XAxis! = XAxis()
    @objc open var xAxis: XAxis {
        return _xAxis
    }
    
    /// 该chart中，是否允许选中高亮
    private var _highlightPerTapEnabled = true
    @objc open var highlightPerTapEnabled: Bool {
        get { return _highlightPerTapEnabled }
        set { _highlightPerTapEnabled = newValue }
    }
    
    /// 是否支持触碰后延时动画
    @objc open var dragDecelerationEnabled = true
    @objc open var isDragDecelerationEnabled: Bool {
        return dragDecelerationEnabled
    }
    
    /// 图例渲染器
    internal var _legendRenderer: LegendRenderer!
    @objc open var legendRenderer: LegendRenderer! {
        return _legendRenderer
    }
    
    /// 动画
    internal var _animator: Animator! = Animator()
    @objc open var chartAnimator: Animator! {
        return _animator
    }
    
    /// 高亮对象的数组
    internal var _highlights = [Highlight]()
    @objc open var highlights: [Highlight] {
        return _highlights
    }
    
    @objc open var lastHighlighted: Highlight?
    
    /// 高亮选中时，气泡说明图等
    @objc open var drawMarkersEnabled = true
    @objc open var marker: IMarker?
    
    
    /// 图例
    internal var _legend: Legend! = Legend()
    @objc open var legend: Legend {
        return _legend
    }
    
    /// ValueFormatter
    internal var _defaultValueFormatter: ChartValueFormatter? = ChartValueFormatter(decimals: 0)
    
    /// value后是否绘制单位
    internal var _drawUnitInChart = false
    
    /// 截获手势事件
    private var _interceptTouchEvents = false
    
    
    @objc open var chartDescription: Description? = Description()
    @objc open weak var delegate: ChartViewDelegate?
    @objc open var highlighter: ChartHighlighter?
    @objc open var renderer: ChartRenderBase?
    
    /// chart的数据
    internal var _data: ChartData?
    
    /// 管理图表的边界等相关约束
    internal var _viewPortHandler: ViewPortHandler!
    
    /// 偏移量是否已计算
    private var _offsetsCalculated = false
    
    /// 无数据时的文案
    @objc open var noDataText = "No chart data available."
    @objc open var noDataFont: NSUIFont! = NSUIFont(name: "HelveticaNeue", size: 12.0)
    @objc open var noDataTextColor: NSUIColor = NSUIColor.black
    open var noDataTextAlignment: NSTextAlignment = .left
    
    /// 附加在viewPort上的偏移量
    @objc open var extraTopOffset: CGFloat = 0.0
    @objc open var extraRightOffset: CGFloat = 0.0
    @objc open var extraBottomOffset: CGFloat = 0.0
    @objc open var extraLeftOffset: CGFloat = 0.0
    @objc open func setExtraOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat){
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    
    // MARK: - 初始化
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {
        #if os(iOS)
            self.backgroundColor = NSUIColor.clear
        #endif
        
        _animator.delegate = self
        
        _viewPortHandler = ViewPortHandler(width: bounds.size.width, height: bounds.size.height)
        _legendRenderer = LegendRenderer(viewPortHandler: _viewPortHandler, legend: _legend)
        
        self.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    // MARK: - 设置Chart数据、绘制相关
    
    /// 设置图表数据
    open var data: ChartData?
    {
        get
        {
            return _data
        }
        set
        {
            _data = newValue
            _offsetsCalculated = false
            
            guard let _data = _data else
            {
                setNeedsDisplay()
                return
            }
            
            // 计算需要多少位数
            setupDefaultFormatter(min: _data.getYMin(), max: _data.getYMax())
            
            for set in _data.dataSets
            {
                if set.needsFormatter || set.valueFormatter === _defaultValueFormatter
                {
                    set.valueFormatter = _defaultValueFormatter
                }
            }
            
            // 数据更新，通知子类
            notifyDataSetChanged()
        }
    }
    
    internal func setupDefaultFormatter(min: Double, max: Double)
    {
        // check if a custom formatter is set or not
        var reference = Double(0.0)
        
        if let data = _data , data.entryCount >= 2
        {
            reference = fabs(max - min)
        }
        else
        {
            let absMin = fabs(min)
            let absMax = fabs(max)
            reference = absMin > absMax ? absMin : absMax
        }
        
    
        if _defaultValueFormatter != nil
        {
            // setup the formatter with a new number of digits
            let digits = reference.decimalPlaces
            
            (_defaultValueFormatter)?.decimals = digits
        }
    }
    
    /// 清除图表数据
    @objc open func clear()
    {
        _data = nil
        _offsetsCalculated = false
        _highlights.removeAll()
        lastHighlighted = nil
        
        setNeedsDisplay()
    }
    
    /// 清除dataSets中所有value
    @objc open func clearValues()
    {
        _data?.clearValues()
        setNeedsDisplay()
    }
    
    /// 判断数据是否为空
    @objc open func isEmpty() -> Bool
    {
        guard let data = _data else { return true }

        if data.entryCount <= 0 {
            return true
        }
        else {
            return false
        }
    }
    
    /// 数据更新通知，供子类重写
    @objc open func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// 数据更新后计算相关偏移量，供子类重写
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// 计算x轴最值及跨度，计算y轴最值，供子类重写
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// 绘制
    open override func draw(_ rect: CGRect)
    {
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        let frame = self.bounds

        if _data === nil && noDataText.count > 0
        {
            context.saveGState()
            defer { context.restoreGState() }

            let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.minimumLineHeight = noDataFont.lineHeight
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = noDataTextAlignment

            ChartUtils.drawMultilineText(
                context: context,
                text: noDataText,
                point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0),
                attributes:
                [.font: noDataFont!,
                 .foregroundColor: noDataTextColor,
                 .paragraphStyle: paragraphStyle],
                constrainedToSize: self.bounds.size,
                anchor: CGPoint(x: 0.5, y: 0.5),
                angleRadians: 0.0)
            
            return
        }
        
        if !_offsetsCalculated
        {
            calculateOffsets()
            _offsetsCalculated = true
        }
    }
    
    internal func drawDescription(context: CGContext)
    {
        // check if description should be drawn
        guard
            let description = chartDescription,
            description.isEnabled,
            let descriptionText = description.text,
            descriptionText.count > 0
            else { return }
        
        let position = description.position ?? CGPoint(x: bounds.width - _viewPortHandler.offsetRight - description.xOffset,
                                                       y: bounds.height - _viewPortHandler.offsetBottom - description.yOffset - description.font.lineHeight)
        
        var attrs = [NSAttributedString.Key : Any]()
        
        attrs[NSAttributedString.Key.font] = description.font
        attrs[NSAttributedString.Key.foregroundColor] = description.textColor

        ChartUtils.drawText(
            context: context,
            text: descriptionText,
            point: position,
            align: description.textAlign,
            attributes: attrs)
    }
    
    // MARK: - 高亮操作

    /// 设置高亮对象集合数据
    @objc open func highlightValues(_ highs: [Highlight]?)
    {
        _highlights = highs ?? [Highlight]()
        
        if _highlights.isEmpty {
            self.lastHighlighted = nil
        }
        else {
            self.lastHighlighted = _highlights[0]
        }
        
        setNeedsDisplay()
    }
    
    /// 执行高亮动作，由外部直接调用 （这几个方法专供混合图表使用）
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        highlightValue(x: x, y: .nan, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: callDelegate)
    }
    
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        guard let data = _data else
        {
            Swift.print("Value not highlighted because data is nil")
            return
        }
        
        if dataSetIndex < 0 || dataSetIndex >= data.dataSetCount
        {
            highlightValue(nil, callDelegate: callDelegate)
        }
        else
        {
            highlightValue(Highlight(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex), callDelegate: callDelegate)
        }
    }
    
    /// 执行高亮动作，由外部直接调用
    @objc open func highlightValue(_ highlight: Highlight?, callDelegate: Bool)
    {
        var entry: ChartDataEntry?
        var h = highlight
        
        if h == nil
        {
            self.lastHighlighted = nil
            _highlights.removeAll(keepingCapacity: false)
        }
        else
        {
            // set the indices to highlight
            entry = _data?.entryForHighlight(h!)
            if entry == nil
            {
                h = nil
                _highlights.removeAll(keepingCapacity: false)
            }
            else
            {
                _highlights = [h!]
            }
        }
        
        if callDelegate, let delegate = delegate
        {
            if let h = h
            {
                // notify the listener
                delegate.chartValueSelected?(self, entry: entry!, highlight: h)
            }
            else
            {
                delegate.chartValueNothingSelected?(self)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }
    
    @objc open func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }
    
    
    // MARK: - 绘制标记视图

    /// draws all MarkerViews on the highlighted positions
    internal func drawMarkers(context: CGContext)
    {
        // if there is no marker view or drawing marker is disabled
        guard let marker = marker , drawMarkersEnabled && _highlights.count > 0 else { return }
        
        for i in 0 ..< _highlights.count
        {
            let highlight = _highlights[i]
            
            guard let
                set = data?.getDataSetByIndex(highlight.dataSetIndex),
                let e = _data?.entryForHighlight(highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * _animator.phaseX)
            {
                continue
            }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            if !_viewPortHandler.isInBounds(x: pos.x, y: pos.y)
            {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
    
    /// - returns: The actual position in pixels of the MarkerView for the given Entry in the given DataSet.
    @objc open func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawX, y: highlight.drawY)
    }
    
    
    // MARK: - 动画相关
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingX, easingY: easingY)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingOptionX, easingOptionY: easingOptionY)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easing)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easing: easing)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easing: easing)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval)
    {
        _animator.animate(yAxisDuration: yAxisDuration)
    }
    
    
    // MARK: - Accessors

    /// - returns: The current y-max value across all DataSets
    open var chartYMax: Double
    {
        return _data?.yMax ?? 0.0
    }

    /// - returns: The current y-min value across all DataSets
    open var chartYMin: Double
    {
        return _data?.yMin ?? 0.0
    }
    
    open var chartXMax: Double
    {
        return _xAxis._axisMaximum
    }
    
    open var chartXMin: Double
    {
        return _xAxis._axisMinimum
    }
    
    open var xRange: Double
    {
        return _xAxis.axisRange
    }
    
    /// 整个ChartView的midPoint
    @objc open var midPoint: CGPoint
    {
        let bounds = self.bounds
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    /// 处理完内部偏移量的contentCenter
    open var centerOffsets: CGPoint
    {
        return _viewPortHandler.contentCenter
    }
    
    /// - returns: The rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    @objc open var contentRect: CGRect
    {
        return _viewPortHandler.contentRect
    }
    
    /// - returns: The ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    @objc open var viewPortHandler: ViewPortHandler!
    {
        return _viewPortHandler
    }
    
    /// - returns: The bitmap that represents the chart.
    @objc open func getChartImage(transparent: Bool) -> NSUIImage?
    {
        NSUIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque || !transparent, NSUIMainScreen()?.nsuiScale ?? 1.0)
        
        guard let context = NSUIGraphicsGetCurrentContext()
            else { return nil }
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: bounds.size)
        
        if isOpaque || !transparent
        {
            // Background color may be partially transparent, we must fill with white if we want to output an opaque image
            context.setFillColor(NSUIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = self.backgroundColor
            {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        nsuiLayer?.render(in: context)
        
        let image = NSUIGraphicsGetImageFromCurrentImageContext()
        
        NSUIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat
    {
        case jpeg
        case png
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// - parameter to: path to the image to save
    /// - parameter format: the format to save
    /// - parameter compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// - returns: `true` if the image was saved successfully
    open func save(to path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
        guard let image = getChartImage(transparent: format != .jpeg) else { return false }
        
        let imageData: Data?
        switch (format)
        {
        case .png: imageData = NSUIImagePNGRepresentation(image)
        case .jpeg: imageData = NSUIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        }
        
        guard let data = imageData else { return false }
        
        do
        {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        catch
        {
            return false
        }
        
        return true
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "bounds" || keyPath == "frame"
        {
            let bounds = self.bounds
            
            if (_viewPortHandler !== nil &&
                (bounds.size.width != _viewPortHandler.chartWidth ||
                bounds.size.height != _viewPortHandler.chartHeight))
            {
                _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                
                // This may cause the chart view to mutate properties affecting the view port -- lets do this
                // before we try to run any pending jobs on the view port itself
                notifyDataSetChanged()
            }
        }
    }
    
    /// 摩擦系数，范围[0, 1)
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    @objc open var dragDecelerationFrictionCoef: CGFloat
    {
        get
        {
            return _dragDecelerationFrictionCoef
        }
        set
        {
            var val = newValue
            if val < 0.0
            {
                val = 0.0
            }
            if val >= 1.0
            {
                val = 0.999
            }
            
            _dragDecelerationFrictionCoef = val
        }
    }
    
    /// The maximum distance in screen pixels away from an entry causing it to highlight.
    /// **default**: 500.0
    open var maxHighlightDistance: CGFloat = 500.0
    
    /// the number of maximum visible drawn values on the chart only active when `drawValuesEnabled` is enabled
    open var maxVisibleCount: Int
    {
        return Int(INT_MAX)
    }
    
    // MARK: - 动画回调
    
    open func animatorUpdated(_ chartAnimator: Animator)
    {
        setNeedsDisplay()
    }
    
    open func animatorStopped(_ chartAnimator: Animator)
    {
        
    }
    
    // MARK: - 手势相关
    
    open override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if !_interceptTouchEvents
        {
            super.nsuiTouchesBegan(touches, withEvent: event)
        }
    }
    
    open override func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if !_interceptTouchEvents
        {
            super.nsuiTouchesMoved(touches, withEvent: event)
        }
    }
    
    open override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if !_interceptTouchEvents
        {
            super.nsuiTouchesEnded(touches, withEvent: event)
        }
    }
    
    open override func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        if !_interceptTouchEvents
        {
            super.nsuiTouchesCancelled(touches, withEvent: event)
        }
    }
}
