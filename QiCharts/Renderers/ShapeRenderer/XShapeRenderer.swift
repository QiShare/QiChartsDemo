//
//  XShapeRenderer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//


import Foundation
import CoreGraphics

open class XShapeRenderer : NSObject, IShapeRenderer
{
    open func renderShape(
        context: CGContext,
        dataSet: ScatterChartDataSet,
        viewPortHandler: ViewPortHandler,
        point: CGPoint,
        color: NSUIColor)
    {
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0
        
        context.setLineWidth(1.0)
        context.setStrokeColor(color.cgColor)
        
        context.beginPath()
        context.move(to: CGPoint(x: point.x - shapeHalf, y: point.y - shapeHalf))
        context.addLine(to: CGPoint(x: point.x + shapeHalf, y: point.y + shapeHalf))
        context.move(to: CGPoint(x: point.x + shapeHalf, y: point.y - shapeHalf))
        context.addLine(to: CGPoint(x: point.x - shapeHalf, y: point.y + shapeHalf))
        context.strokePath()
    }
}
