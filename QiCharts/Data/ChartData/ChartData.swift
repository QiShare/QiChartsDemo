//
//  ChartData.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

open class ChartData: NSObject
{
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    internal var _leftAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _leftAxisMin: Double = Double.greatestFiniteMagnitude
    internal var _rightAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _rightAxisMin: Double = Double.greatestFiniteMagnitude
    
    internal var _dataSets = [ChartDataSet]()
    
    public override init()
    {
        super.init()
        
        _dataSets = [ChartDataSet]()
    }
    
    @objc public init(dataSets: [ChartDataSet]?)
    {
        super.init()
        
        _dataSets = dataSets ?? [ChartDataSet]()
        
        self.initialize(dataSets: _dataSets)
    }
    
    @objc public convenience init(dataSet: ChartDataSet?)
    {
        self.init(dataSets: dataSet === nil ? nil : [dataSet!])
    }
    
    internal func initialize(dataSets: [ChartDataSet])
    {
        notifyDataChanged()
    }
    
    /// Call this method to let the ChartData know that the underlying data has changed.
    /// Calling this performs all necessary recalculations needed when the contained data has changed.
    @objc open func notifyDataChanged()
    {
        calcMinMax()
    }
    
    @objc open func calcMinMaxY(fromX: Double, toX: Double)
    {
        for set in _dataSets
        {
            set.calcMinMaxY(fromX: fromX, toX: toX)
        }
        
        // apply the new data
        calcMinMax()
    }
    
    /// calc minimum and maximum y value over all datasets
    @objc open func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        for set in _dataSets
        {
            calcMinMax(dataSet: set)
        }
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        // left axis
        let firstLeft = getFirstLeft(dataSets: dataSets)
        
        if firstLeft !== nil
        {
            _leftAxisMax = firstLeft!.yMax
            _leftAxisMin = firstLeft!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .left
                {
                    if dataSet.yMin < _leftAxisMin
                    {
                        _leftAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _leftAxisMax
                    {
                        _leftAxisMax = dataSet.yMax
                    }
                }
            }
        }
        
        // right axis
        let firstRight = getFirstRight(dataSets: dataSets)
        
        if firstRight !== nil
        {
            _rightAxisMax = firstRight!.yMax
            _rightAxisMin = firstRight!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .right
                {
                    if dataSet.yMin < _rightAxisMin
                    {
                        _rightAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _rightAxisMax
                    {
                        _rightAxisMax = dataSet.yMax
                    }
                }
            }
        }
    }
    
    /// Adjusts the current minimum and maximum values based on the provided Entry object.
    @objc open func calcMinMax(entry e: ChartDataEntry, axis: YAxis.AxisDependency)
    {
        if _yMax < e.y
        {
            _yMax = e.y
        }
        
        if _yMin > e.y
        {
            _yMin = e.y
        }
        
        if _xMax < e.x
        {
            _xMax = e.x
        }
        
        if _xMin > e.x
        {
            _xMin = e.x
        }
        
        if axis == .left
        {
            if _leftAxisMax < e.y
            {
                _leftAxisMax = e.y
            }
            
            if _leftAxisMin > e.y
            {
                _leftAxisMin = e.y
            }
        }
        else
        {
            if _rightAxisMax < e.y
            {
                _rightAxisMax = e.y
            }
            
            if _rightAxisMin > e.y
            {
                _rightAxisMin = e.y
            }
        }
    }
    
    /// Adjusts the minimum and maximum values based on the given DataSet.
    @objc open func calcMinMax(dataSet d: ChartDataSet)
    {
        if _yMax < d.yMax
        {
            _yMax = d.yMax
        }
        
        if _yMin > d.yMin
        {
            _yMin = d.yMin
        }
        
        if _xMax < d.xMax
        {
            _xMax = d.xMax
        }
        
        if _xMin > d.xMin
        {
            _xMin = d.xMin
        }
        
        if d.axisDependency == .left
        {
            if _leftAxisMax < d.yMax
            {
                _leftAxisMax = d.yMax
            }
            
            if _leftAxisMin > d.yMin
            {
                _leftAxisMin = d.yMin
            }
        }
        else
        {
            if _rightAxisMax < d.yMax
            {
                _rightAxisMax = d.yMax
            }
            
            if _rightAxisMin > d.yMin
            {
                _rightAxisMin = d.yMin
            }
        }
    }
    
    /// - returns: The number of LineDataSets this object contains
    @objc open var dataSetCount: Int
    {
        return _dataSets.count
    }
    
    /// - returns: The smallest y-value the data object contains.
    @objc open var yMin: Double
    {
        return _yMin
    }
    
    @nonobjc
    open func getYMin() -> Double
    {
        return _yMin
    }
    
    @objc open func getYMin(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if _leftAxisMin == Double.greatestFiniteMagnitude
            {
                return _rightAxisMin
            }
            else
            {
                return _leftAxisMin
            }
        }
        else
        {
            if _rightAxisMin == Double.greatestFiniteMagnitude
            {
                return _leftAxisMin
            }
            else
            {
                return _rightAxisMin
            }
        }
    }
    
    /// - returns: The greatest y-value the data object contains.
    @objc open var yMax: Double
    {
        return _yMax
    }
    
    @nonobjc
    open func getYMax() -> Double
    {
        return _yMax
    }
    
    @objc open func getYMax(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if _leftAxisMax == -Double.greatestFiniteMagnitude
            {
                return _rightAxisMax
            }
            else
            {
                return _leftAxisMax
            }
        }
        else
        {
            if _rightAxisMax == -Double.greatestFiniteMagnitude
            {
                return _leftAxisMax
            }
            else
            {
                return _rightAxisMax
            }
        }
    }
    
    /// - returns: The minimum x-value the data object contains.
    @objc open var xMin: Double
    {
        return _xMin
    }
    /// - returns: The maximum x-value the data object contains.
    @objc open var xMax: Double
    {
        return _xMax
    }
    
    /// - returns: All DataSet objects this ChartData object holds.
    @objc open var dataSets: [ChartDataSet]
    {
        get
        {
            return _dataSets
        }
        set
        {
            _dataSets = newValue
            notifyDataChanged()
        }
    }
    
    /// 根据一个Label获取某DataSet的Index
    internal func getDataSetIndexByLabel(_ label: String, ignorecase: Bool) -> Int
    {
        if ignorecase
        {
            for i in 0 ..< dataSets.count
            {
                if dataSets[i].label == nil
                {
                    continue
                }
                if (label.caseInsensitiveCompare(dataSets[i].label!) == ComparisonResult.orderedSame)
                {
                    return i
                }
            }
        }
        else
        {
            for i in 0 ..< dataSets.count
            {
                if label == dataSets[i].label
                {
                    return i
                }
            }
        }
        
        return -1
    }
    
    /// - returns: 获取所有dataSet的所有labels
    internal func dataSetLabels() -> [String]
    {
        var labelArr = [String]()
        
        for i in 0 ..< _dataSets.count
        {
            if dataSets[i].label == nil
            {
                continue
            }
            
            labelArr[i] = _dataSets[i].label!
        }
        
        return labelArr
    }
    
    /// 根据Highlight获取某entry
    @objc open func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        if highlight.dataSetIndex >= dataSets.count
        {
            return nil
        }
        else
        {
            return dataSets[highlight.dataSetIndex].entryForXValue(highlight.x, closestToY: highlight.y)
        }
    }
    
    /// 根据Label获取某个DataSet
    @objc open func getDataSetByLabel(_ label: String, ignorecase: Bool) -> ChartDataSet?
    {
        let index = getDataSetIndexByLabel(label, ignorecase: ignorecase)
        
        if index < 0 || index >= _dataSets.count
        {
            return nil
        }
        else
        {
            return _dataSets[index]
        }
    }
    
    @objc open func getDataSetByIndex(_ index: Int) -> ChartDataSet!
    {
        if index < 0 || index >= _dataSets.count
        {
            return nil
        }
        
        return _dataSets[index]
    }
    
    @objc open func addDataSet(_ dataSet: ChartDataSet!)
    {
        calcMinMax(dataSet: dataSet)
        
        _dataSets.append(dataSet)
    }
    
    /// 向某DataSet追加一个Entry
    @objc open func addEntry(_ e: ChartDataEntry, dataSetIndex: Int)
    {
        if _dataSets.count > dataSetIndex && dataSetIndex >= 0
        {
            let set = _dataSets[dataSetIndex]
            
            if !set.addEntry(e) { return }
            
            calcMinMax(entry: e, axis: set.axisDependency)
        }
        else
        {
            print("ChartData.addEntry() - Cannot add Entry because dataSetIndex too high or too low.", terminator: "\n")
        }
    }
    
    /// - returns: 根据entry获取DataSet
    @objc open func getDataSetForEntry(_ e: ChartDataEntry!) -> ChartDataSet?
    {
        if e == nil
        {
            return nil
        }
        
        for i in 0 ..< _dataSets.count
        {
            let set = _dataSets[i]
            
            if e === set.entryForXValue(e.x, closestToY: e.y)
            {
                return set
            }
        }
        
        return nil
    }

    /// - returns: 获取DataSet的index
    @objc open func indexOfDataSet(_ dataSet: ChartDataSet) -> Int
    {
        for i in 0 ..< _dataSets.count
        {
            if _dataSets[i] === dataSet
            {
                return i
            }
        }
        
        return -1
    }
    
    /// - returns: 获取第一个需要绘制leftAxis的DataSet
    @objc open func getFirstLeft(dataSets: [ChartDataSet]) -> ChartDataSet?
    {
        for dataSet in dataSets
        {
            if dataSet.axisDependency == .left
            {
                return dataSet
            }
        }
        
        return nil
    }
    
    /// - returns: 获取第一个需要绘制rightAxis的DataSet
    @objc open func getFirstRight(dataSets: [ChartDataSet]) -> ChartDataSet?
    {
        for dataSet in _dataSets
        {
            if dataSet.axisDependency == .right
            {
                return dataSet
            }
        }
        
        return nil
    }
    
    /// - returns: All colors used across all DataSet objects this object represents.
    @objc open func getColors() -> [NSUIColor]?
    {
        var colors = [NSUIColor]()
        
        for i in 0 ..< _dataSets.count
        {
            let clrs = _dataSets[i].colors
            
            for clr in clrs
            {
                colors.append(clr)
            }
        }
        
        return colors
    }
    
    
    /// 是否绘制Values的值
    @objc open func setDrawValues(_ enabled: Bool)
    {
        for set in dataSets
        {
            set.drawValuesEnabled = enabled
        }
    }
    
    @objc open func setValueFormatter(_ formatter: ChartValueFormatter?)
    {
        guard let formatter = formatter
            else { return }
        
        for set in dataSets
        {
            set.valueFormatter = formatter
        }
    }
    
    @objc open func setValueTextColor(_ color: NSUIColor!)
    {
        for set in dataSets
        {
            set.valueTextColor = color ?? set.valueTextColor
        }
    }
    
    @objc open func setValueFont(_ font: NSUIFont!)
    {
        for set in dataSets
        {
            set.valueFont = font ?? set.valueFont
        }
    }
    
    
    /// 是否可以高亮显示
    @objc open var highlightEnabled: Bool
    {
        get
        {
            for set in dataSets
            {
                if !set.highlightEnabled
                {
                    return false
                }
            }
            
            return true
        }
        set
        {
            for set in dataSets
            {
                set.highlightEnabled = newValue
            }
        }
    }
    
    
    /// 清除全部dataSets
    @objc open func clearValues()
    {
        dataSets.removeAll(keepingCapacity: false)
        notifyDataChanged()
    }
    
    /// - returns: DataSet是否包含某dataSet
    @objc open func contains(dataSet: ChartDataSet) -> Bool
    {
        for set in dataSets
        {
            if set === dataSet
            {
                return true
            }
        }
        
        return false
    }
    
    /// - returns: 获取所有DataSet中所有entry的数量之和
    @objc open var entryCount: Int
    {
        var count = 0
        
        for set in _dataSets
        {
            count += set.entryCount
        }
        
        return count
    }

    /// - returns: 获取EntryCount最大的那个DataSet
    @objc open var maxEntryCountSet: ChartDataSet?
    {
        if _dataSets.count == 0
        {
            return nil
        }
        
        var max = _dataSets[0]
        
        for set in _dataSets
        {
            if set.entryCount > max.entryCount
            {
                max = set
            }
        }
        
        return max
    }
}
