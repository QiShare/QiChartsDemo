//
//  LineChartData.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation

/// Data object that encapsulates all data associated with a LineChart.
open class LineChartData: ChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
}
