//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-value is not found.
@objc
public enum ChartDataSetRounding: Int
{
    case up = 0
    case down = 1
    case closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart
/// (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
open class ChartDataSet: NSObject
{
    // MARK: - Styling functions and accessors
    
    /// 描述DataSet的标签
    open var label: String? = "DataSet"
    
    /// 该DataSet对应的那个轴需要被绘制
    open var axisDependency = YAxis.AxisDependency.left
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    open var colors = [NSUIColor]()
    
    /// - returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    open func color(atIndex index: Int) -> NSUIColor
    {
        var index = index
        if index < 0
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    /// Adds a new color to the colors array of the DataSet.
    /// - parameter color: the color to add
    open func addColor(_ color: NSUIColor)
    {
        colors.append(color)
    }
    
    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    open func setColor(_ color: NSUIColor)
    {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }
    
    /// Sets colors to a single color a specific alpha value.
    /// - parameter color: the color to set
    /// - parameter alpha: alpha to apply to the set `color`
    @objc open func setColor(_ color: NSUIColor, alpha: CGFloat)
    {
        setColor(color.withAlphaComponent(alpha))
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    @objc open func setColors(_ colors: [NSUIColor], alpha: CGFloat)
    {
        var colorsWithAlpha = colors
        
        for i in 0 ..< colorsWithAlpha.count
        {
            colorsWithAlpha[i] = colorsWithAlpha[i] .withAlphaComponent(alpha)
        }
        
        self.colors = colorsWithAlpha
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    open func setColors(_ colors: NSUIColor...)
    {
        self.colors = colors
    }
    
    /// if true, value highlighting is enabled
    open var highlightEnabled = true
    
    /// Custom formatter that is used instead of the auto-formatter if set
    internal var _valueFormatter: DefaultValueFormatter?
    
    /// Custom formatter that is used instead of the auto-formatter if set
    open var valueFormatter: DefaultValueFormatter?
    {
        get
        {
            if needsFormatter
            {
                return ChartUtils.defaultValueFormatter()
            }
            
            return _valueFormatter
        }
        set
        {
            if newValue == nil { return }
            
            _valueFormatter = newValue
        }
    }
    
    open var needsFormatter: Bool
    {
        return _valueFormatter == nil
    }
    
    /// the font for the value-text labels
    open var valueFont: NSUIFont = NSUIFont.systemFont(ofSize: 7.0)
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    open var valueColors = [NSUIColor]()
    
    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    open var valueTextColor: NSUIColor
    {
        get
        {
            return valueColors[0]
        }
        set
        {
            valueColors.removeAll(keepingCapacity: false)
            valueColors.append(newValue)
        }
    }
    
    /// - returns: The color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    open func valueTextColorAt(_ index: Int) -> NSUIColor
    {
        var index = index
        if index < 0
        {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }
    
    
    /// The form to draw for this dataset in the legend.
    open var form = Legend.Form.default
    
    /// The form size to draw for this dataset in the legend.
    ///
    /// Return `NaN` to use the default legend form size.
    open var formSize: CGFloat = CGFloat.nan
    
    /// The line width for drawing the form of this dataset in the legend
    ///
    /// Return `NaN` to use the default legend form line width.
    open var formLineWidth: CGFloat = CGFloat.nan
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    open var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    open var formLineDashLengths: [CGFloat]? = nil
    
    /// Set this to true to draw y-values on the chart.
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no values will be drawn even if this is enabled.
    open var drawValuesEnabled = true

    /// Set this to true to draw y-icons on the chart.
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no icons will be drawn even if this is enabled.
    open var drawIconsEnabled = true
    
    /// Offset of icons drawn on the chart.
    ///
    /// For all charts except Pie and Radar it will be ordinary (x offset, y offset).
    ///
    /// For Pie and Radar chart it will be (y offset, distance from center offset); so if you want icon to be rendered under value, you should increase X component of CGPoint, and if you want icon to be rendered closet to center, you should decrease height component of CGPoint.
    open var iconsOffset = CGPoint(x: 0, y: 0)
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    open var visible = true
    
    
    // MARK: - init
    
    public required override init()
    {
        values = []
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.black)
    }
    
    public init(label: String?)
    {
        values = []
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.black)
        
        self.label = label
    }
    
    @objc public init(values: [ChartDataEntry]?, label: String?)
    {
        self.values = values ?? []
        super.init()

        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.black)
        self.calcMinMax()
    }
    
    @objc public convenience init(values: [ChartDataEntry]?)
    {
        self.init(values: values, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors

    /// *
    /// - note: Calls `notifyDataSetChanged()` after setting a new value.
    /// - returns: The array of y-values that this DataSet represents.
    /// the entries that this dataset represents / holds together
    @objc open var values: [ChartDataEntry]
        {
        didSet
        {
            if isIndirectValuesCall {
                isIndirectValuesCall = false
                return
            }
            calcMinMax()
        }
    }
    // TODO: Temporary fix for performance. Will be removed in 4.0
    private var isIndirectValuesCall = false

    /// maximum y-value in the value array
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum y-value in the value array
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    
    /// maximum x-value in the value array
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum x-value in the value array
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    
    open func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude

        guard !values.isEmpty else { return }

        values.forEach { calcMinMax(entry: $0) }
    }
    
    open func calcMinMaxY(fromX: Double, toX: Double)
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude

        guard !values.isEmpty else { return }
        
        let indexFrom = entryIndex(x: fromX, closestToY: Double.nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: Double.nan, rounding: .up)
        
        guard !(indexTo < indexFrom) else { return }
        
        (indexFrom...indexTo).forEach {
            // only recalculate y
            calcMinMaxY(entry: values[$0])
        }
    }
    
    @objc open func calcMinMaxX(entry e: ChartDataEntry)
    {
        if e.x < _xMin
        {
            _xMin = e.x
        }
        if e.x > _xMax
        {
            _xMax = e.x
        }
    }
    
    @objc open func calcMinMaxY(entry e: ChartDataEntry)
    {
        if e.y < _yMin
        {
            _yMin = e.y
        }
        if e.y > _yMax
        {
            _yMax = e.y
        }
    }
    
    /// Updates the min and max x and y value of this DataSet based on the given Entry.
    ///
    /// - parameter e:
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
    }
    
    /// - returns: The minimum y-value this DataSet holds
    open var yMin: Double { return _yMin }
    
    /// - returns: The maximum y-value this DataSet holds
    open var yMax: Double { return _yMax }
    
    /// - returns: The minimum x-value this DataSet holds
    open var xMin: Double { return _xMin }
    
    /// - returns: The maximum x-value this DataSet holds
    open var xMax: Double { return _xMax }
    
    /// - returns: The number of y-values this DataSet represents
    open var entryCount: Int { return values.count }
    
    /// - returns: The entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    open func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        guard i >= values.startIndex, i < values.endIndex else {
            return nil
        }
        return values[i]
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    open func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1
        {
            return values[index]
        }
        return nil
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    open func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> ChartDataEntry?
    {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    /// - returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    open func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = values.startIndex
        var high = values.endIndex - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = values[m]
            
            // if we have a match
            if xValue == entry.x
            {
                while m > 0 && values[m - 1].x == xValue
                {
                    m -= 1
                }
                
                high = values.endIndex
                
                // loop over all "equal" entries
                while m < high
                {
                    entry = values[m]
                    if entry.x == xValue
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                    
                    m += 1
                }
                
                break
            }
            else
            {
                if xValue > entry.x
                {
                    low = m + 1
                }
                else
                {
                    high = m - 1
                }
            }
        }
        
        return entries
    }
    
    /// - returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    ///
    /// - parameter xValue: x-value of the entry to search for
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: Rounding method if exact value was not found
    open func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        var low = values.startIndex
        var high = values.endIndex - 1
        var closest = high
        
        while low < high
        {
            let m = (low + high) / 2
            
            let d1 = values[m].x - xValue
            let d2 = values[m + 1].x - xValue
            let ad1 = abs(d1), ad2 = abs(d2)
            
            if ad2 < ad1
            {
                // [m + 1] is closer to xValue
                // Search in an higher place
                low = m + 1
            }
            else if ad1 < ad2
            {
                // [m] is closer to xValue
                // Search in a lower place
                high = m
            }
            else
            {
                // We have multiple sequential x-value with same distance
                
                if d1 >= 0.0
                {
                    // Search in a lower place
                    high = m
                }
                else if d1 < 0.0
                {
                    // Search in an higher place
                    low = m + 1
                }
            }
            
            closest = high
        }
        
        if closest != -1
        {
            let closestXValue = values[closest].x
            
            if rounding == .up
            {
                // If rounding up, and found x-value is lower than specified x, and we can go upper...
                if closestXValue < xValue && closest < values.endIndex - 1
                {
                    closest += 1
                }
            }
            else if rounding == .down
            {
                // If rounding down, and found x-value is upper than specified x, and we can go lower...
                if closestXValue > xValue && closest > 0
                {
                    closest -= 1
                }
            }
            
            // Search by closest to y-value
            if !yValue.isNaN
            {
                while closest > 0 && values[closest - 1].x == closestXValue
                {
                    closest -= 1
                }
                
                var closestYValue = values[closest].y
                var closestYIndex = closest
                
                while true
                {
                    closest += 1
                    if closest >= values.endIndex { break }
                    
                    let value = values[closest]
                    
                    if value.x != closestXValue { break }
                    if abs(value.y - yValue) < abs(closestYValue - yValue)
                    {
                        closestYValue = yValue
                        closestYIndex = closest
                    }
                }
                
                closest = closestYIndex
            }
        }
        
        return closest
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    open func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for i in 0 ..< values.count
        {
            if values[i] === e
            {
                return i
            }
        }
        
        return -1
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: True
    open func addEntry(_ e: ChartDataEntry) -> Bool
    {
        calcMinMax(entry: e)

        isIndirectValuesCall = true
        values.append(e)
        
        return true
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: True
    open func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        calcMinMax(entry: e)
        
        isIndirectValuesCall = true
        if values.count > 0 && values.last!.x > e.x
        {
            var closestIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            while values[closestIndex].x < e.x
            {
                closestIndex += 1
            }
            values.insert(e, at: closestIndex)
        }
        else
        {
            values.append(e)
        }
        
        return true
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: `true` if contains the entry, `false` if not.
    open func contains(_ e: ChartDataEntry) -> Bool
    {
        for entry in values
        {
            if entry == e
            {
                return true
            }
        }
        
        return false
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    open func clear()
    {
        values.removeAll(keepingCapacity: true)
    }
    
    // MARK: - Data functions and accessors

    // MARK: - NSCopying
    
    open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = type(of: self).init()
        
        copy.colors = colors
        copy.valueColors = valueColors
        copy.label = label
        
        copy.values = values
        copy._yMax = _yMax
        copy._yMin = _yMin

        return copy
    }
    
    // MARK: - NSObject
    
    open override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(type(of: self)), self.label ?? "", self.entryCount])
    }
    
    open override var debugDescription: String
    {
        var desc = description + ":"
        
        for i in 0 ..< self.entryCount
        {
            desc += "\n" + (self.entryForIndex(i)?.description ?? "")
        }
        
        return desc
    }
}
