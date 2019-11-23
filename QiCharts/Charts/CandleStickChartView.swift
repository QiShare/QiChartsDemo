//
//  CandleStickChartView.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class CandleStickChartView: BarLineScatterCandleChartViewBase
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = CandleStickChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    // MARK: - CandleChartDataProvider
    
    open var candleData: CandleChartData?
    {
        return _data as? CandleChartData
    }
}
