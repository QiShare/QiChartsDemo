//
//  IShapeRenderer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc
public protocol IShapeRenderer: class
{
    /// Renders the provided ScatterDataSet with a shape.
    ///
    /// - parameter context:         CGContext for drawing on
    /// - parameter dataSet:         The DataSet to be drawn
    /// - parameter viewPortHandler: Contains information about the current state of the view
    /// - parameter point:           Position to draw the shape at
    /// - parameter color:           Color to draw the shape
    func renderShape(
        context: CGContext,
        dataSet: ScatterChartDataSet,
        viewPortHandler: ViewPortHandler,
        point: CGPoint,
        color: NSUIColor)
}
