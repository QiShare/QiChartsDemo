//
//  ScatterChartView.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

/// The ScatterChart. Draws dots, triangles, squares and custom shapes into the chartview.
open class ScatterChartView: BarLineScatterCandleChartViewBase
{
    open override func initialize()
    {
        super.initialize()
        
        renderer = ScatterChartRenderer(chartView: self, animator: _animator, viewPortHandler: _viewPortHandler)

        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5
    }
    
    // MARK: - ScatterChartDataProvider
    
    open var scatterData: ScatterChartData? { return _data as? ScatterChartData }
}
