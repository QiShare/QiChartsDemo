//
//  RadarChartData.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics


open class RadarChartData: ChartData
{
    @objc open var highlightColor = NSUIColor(red: 255.0/255.0, green: 187.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    @objc open var highlightLineWidth = CGFloat(1.0)
    @objc open var highlightLineDashPhase = CGFloat(0.0)
    @objc open var highlightLineDashLengths: [CGFloat]?
    
    /// Sets labels that should be drawn around the RadarChart at the end of each web line.
    @objc open var labels = [String]()
    
    /// Sets the labels that should be drawn around the RadarChart at the end of each web line.
    open func setLabels(_ labels: String...)
    {
        self.labels = labels
    }
    
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    open override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        return getDataSetByIndex(highlight.dataSetIndex)?.entryForIndex(Int(highlight.x))
    }
}
