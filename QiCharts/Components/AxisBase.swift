//
//  AxisBase.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc(ChartAxisValueFormatterDelegate)
public protocol AxisValueFormatterDelegate: class
{
    
    /// - 为X轴专用（需设置delegate）
    /// - parameter value:  the value that is currently being drawn
    /// - parameter axis:   the axis that the value belongs to
    func stringForValue(_ value: Double, axis: AxisBase?) -> String
}

/// Base class for all axes
@objc(ChartAxisBase)
open class AxisBase: ComponentBase
{
    public override init()
    {
        super.init()
    }
    
    @objc open weak var delegate: AxisValueFormatterDelegate?
    
    @objc open var labelFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var labelTextColor = NSUIColor.black
    
    @objc open var axisLineColor = NSUIColor.gray
    @objc open var axisLineWidth = CGFloat(0.5)
    @objc open var axisLineDashPhase = CGFloat(0.0)
    @objc open var axisLineDashLengths: [CGFloat]!
    
    @objc open var gridColor = NSUIColor.gray.withAlphaComponent(0.9)
    @objc open var gridLineWidth = CGFloat(0.5)
    @objc open var gridLineDashPhase = CGFloat(0.0)
    @objc open var gridLineDashLengths: [CGFloat]!
    @objc open var gridLineCap = CGLineCap.butt
    
    @objc open var drawGridLinesEnabled = true
    @objc open var drawAxisLineEnabled = true
    
    /// 轴上的标签是否可绘制
    @objc open var drawLabelsEnabled = true
    
    /// 使标签剧中绘制（针对分组柱状图图）
    private var _centerAxisLabelsEnabled = false
    @objc open var centerAxisLabelsEnabled: Bool {
        get { return _centerAxisLabelsEnabled && entryCount > 0 }
        set { _centerAxisLabelsEnabled = newValue }
    }
    
    /// 限制线数组
    private var _limitLines = [ChartLimitLine]()
    @objc open var limitLines : [ChartLimitLine] {
        return _limitLines
    }
    
    /// 限制线是否绘制在数据之下
    @objc open var drawLimitLinesBehindDataEnabled = false
    
    /// 是否强制y轴标签的数目
    @objc open var forceLabelsEnabled = false
    
    /// 开启抗锯齿
    @objc open var gridAntialiasEnabled = true
    
    /// entry数组
    @objc open var entries = [Double]()
    
    /// 仅用于获取居中标签的Entry数目
    @objc open var centeredEntries = [Double]()
    
    /// 图例包括的entry个数
    @objc open var entryCount: Int { return entries.count }
    
    /// 标签数量
    private var _labelCount = Int(6)
    
    /// 小数点后的位数
    @objc open var decimals: Int = 0
    
    /// 粒度属性，为true时可以避免轴上值的重复
    @objc open var granularityEnabled = false
    
    /// 粒度的值（可以避免缩放时，值的重复）
    private var _granularity = Double(1.0)
    @objc open var granularity: Double {
        get { return _granularity }
        set {
            _granularity = newValue
            granularityEnabled = true
        }
    }
    
    /// 获取最长的标签
    @objc open func getLongestLabel() -> String
    {
        var longest = ""
        
        for i in 0 ..< entries.count
        {
            let text = getFormattedLabel(i)
            
            if longest.count < text.count
            {
                longest = text
            }
        }
        
        return longest
    }
    
    /// 获取格式化的标签
    @objc open func getFormattedLabel(_ index: Int) -> String
    {
        if index < 0 || index >= entries.count
        {
            return ""
        }
        
        if let delegate = delegate
        {
            return delegate.stringForValue(entries[index], axis: self)
        }
        else {
            return valueFormatter?.stringForValue(entries[index], axis: self) ?? ""
        }
    }
    
    private var _axisValueFormatter: ChartAxisValueFormatter?
    @objc open var valueFormatter: ChartAxisValueFormatter?
    {
        get {
            if _axisValueFormatter == nil || (_axisValueFormatter != nil && _axisValueFormatter!.hasAutoDecimals && _axisValueFormatter!.decimals != decimals) {
                
                _axisValueFormatter = ChartAxisValueFormatter(decimals: decimals)
            }
            
            return _axisValueFormatter
        }
        set {
            _axisValueFormatter = newValue ?? ChartAxisValueFormatter(decimals: decimals)
        }
    }
    
    /// 最小间距，用于自动计算 axisMinimum
    @objc open var spaceMin: Double = 0.0
    
    /// 最大间距，用于自动计算 axisMaximum
    @objc open var spaceMax: Double = 0.0
    
    /// 轴上值的总跨度
    @objc open var axisRange = Double(0)
    
    /// 轴上最少的标签数目
    @objc open var axisMinLabels = Int(2) {
        didSet { axisMinLabels = axisMinLabels > 0 ? axisMinLabels : oldValue }
    }
    
    /// /// 轴上最多的标签数目
    @objc open var axisMaxLabels = Int(25) {
        didSet { axisMinLabels = axisMaxLabels > 0 ? axisMaxLabels : oldValue }
    }
    
    /// 获取轴上的标签数目
    @objc open var labelCount: Int
    {
        get
        {
            return _labelCount
        }
        set
        {
            _labelCount = newValue
            
            if _labelCount > axisMaxLabels
            {
                _labelCount = axisMaxLabels
            }
            if _labelCount < axisMinLabels
            {
                _labelCount = axisMinLabels
            }
            
            forceLabelsEnabled = false
        }
    }
    
    @objc open func setLabelCount(_ count: Int, force: Bool)
    {
        self.labelCount = count
        forceLabelsEnabled = force
    }
    
    
    @objc open func addLimitLine(_ line: ChartLimitLine)
    {
        _limitLines.append(line)
    }
    
    // MARK: Custom axis ranges
    
    /// 自定义的轴最小值
    internal var _customAxisMin: Bool = false
    @objc open var isAxisMinCustom: Bool {
        return _customAxisMin
    }
    
    /// 轴最小值
    internal var _axisMinimum = Double(0)
    @objc open var axisMinimum: Double
    {
        get
        {
            return _axisMinimum
        }
        set
        {
            _customAxisMin = true
            _axisMinimum = newValue
            axisRange = abs(_axisMaximum - newValue)
        }
    }
    
    @objc open func resetCustomAxisMin()
    {
        _customAxisMin = false
    }
    
    /// 自定义的轴最大值
    internal var _customAxisMax: Bool = false
    @objc open var isAxisMaxCustom: Bool {
        return _customAxisMax
    }
    
    /// 轴最大值
    internal var _axisMaximum = Double(0)
    @objc open var axisMaximum: Double
    {
        get
        {
            return _axisMaximum
        }
        set
        {
            _customAxisMax = true
            _axisMaximum = newValue
            axisRange = abs(newValue - _axisMinimum)
        }
    }
    
    @objc open func resetCustomAxisMax()
    {
        _customAxisMax = false
    }
    
    ///  计算最大值与最小值之间的跨度（其中x轴自定义，y轴取决于chartData）
    @objc open func calculate(min dataMin: Double, max dataMax: Double)
    {
        // if custom, use value as is, else use data value
        var min = _customAxisMin ? _axisMinimum : (dataMin - spaceMin)
        var max = _customAxisMax ? _axisMaximum : (dataMax + spaceMax)
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        _axisMinimum = min
        _axisMaximum = max
        
        // actual range
        axisRange = abs(max - min)
    }
}
