//
//  PieData.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

open class PieChartData: ChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }

    /// - returns: All DataSet objects this ChartData object holds.
    @objc open override var dataSets: [ChartDataSet]
    {
        get
        {
            assert(super.dataSets.count <= 1, "Found multiple data sets while pie chart only allows one")
            return super.dataSets
        }
        set
        {
            super.dataSets = newValue
        }
    }

    @objc var dataSet: PieChartDataSet?
    {
        get
        {
            return dataSets.count > 0 ? dataSets[0] as? PieChartDataSet : nil
        }
        set
        {
            if let newValue = newValue
            {
                dataSets = [newValue]
            }
            else
            {
                dataSets = []
            }
        }
    }
    
    open override func getDataSetByIndex(_ index: Int) -> ChartDataSet?
    {
        if index != 0
        {
            return nil
        }
        return super.getDataSetByIndex(index)
    }
    
    open override func getDataSetByLabel(_ label: String, ignorecase: Bool) -> ChartDataSet?
    {
        if dataSets.count == 0 || dataSets[0].label == nil
        {
            return nil
        }
        
        if ignorecase
        {
            if let label = dataSets[0].label, label.caseInsensitiveCompare(label) == .orderedSame
            {
                return dataSets[0]
            }
        }
        else
        {
            if label == dataSets[0].label
            {
                return dataSets[0]
            }
        }
        return nil
    }
    
    open override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        return dataSet?.entryForIndex(Int(highlight.x))
    }
    
    open override func addDataSet(_ d: ChartDataSet!)
    {   
        super.addDataSet(d)
    }
    
    /// - returns: The total y-value sum across all DataSet objects the this object represents.
    @objc open var yValueSum: Double
    {
        guard let dataSet = dataSet else { return 0.0 }
        
        var yValueSum: Double = 0.0
        
        for i in 0..<dataSet.entryCount
        {
            yValueSum += dataSet.entryForIndex(i)?.y ?? 0.0
        }
        
        return yValueSum
    }
}
