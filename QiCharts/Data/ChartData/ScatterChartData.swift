//
//  ScatterChartData.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class ScatterChartData: ChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    /// - returns: The maximum shape-size across all DataSets.
    @objc open func getGreatestShapeSize() -> CGFloat
    {
        var max = CGFloat(0.0)
        
        for set in _dataSets
        {
            let scatterDataSet = set as? ScatterChartDataSet
            
            if scatterDataSet == nil
            {
                print("ScatterChartData: Found a DataSet which is not a ScatterChartDataSet", terminator: "\n")
            }
            else if let size = scatterDataSet?.scatterShapeSize, size > max
            {
                max = size
            }
        }
        
        return max
    }
}
