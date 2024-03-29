//
//  ScatterChartRenderer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class ScatterChartRenderer: LineScatterCandleRadarRenderer
{
    @objc open weak var chartView: ScatterChartView?
    
    @objc public init(chartView: ScatterChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chartView = chartView
    }
    
    open override func drawData(context: CGContext)
    {
        guard let scatterData = chartView?.scatterData else { return }
        
        for i in 0 ..< scatterData.dataSetCount
        {
            guard let set = scatterData.getDataSetByIndex(i) else { continue }
            
            if set.visible
            {
                if !(set is ScatterChartDataSet)
                {
                    fatalError("Datasets for ScatterChartRenderer must conform to ScatterChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! ScatterChartDataSet)
            }
        }
    }
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: ScatterChartDataSet)
    {
        guard let chartView = chartView else { return }
        
        let trans = chartView.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if let renderer = dataSet.shapeRenderer
        {
            context.saveGState()
            
            for j in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                point.x = CGFloat(e.x)
                point.y = CGFloat(e.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                if !viewPortHandler.isInBoundsRight(point.x)
                {
                    break
                }
                
                if !viewPortHandler.isInBoundsLeft(point.x) ||
                    !viewPortHandler.isInBoundsY(point.y)
                {
                    continue
                }
                
                renderer.renderShape(context: context, dataSet: dataSet, viewPortHandler: viewPortHandler, point: point, color: dataSet.color(atIndex: j))
            }
            
            context.restoreGState()
        }
        else
        {
            print("There's no IShapeRenderer specified for ScatterDataSet", terminator: "\n")
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let chartView = chartView,
            let scatterData = chartView.scatterData
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(chartView: chartView)
        {
            guard let dataSets = scatterData.dataSets as? [ScatterChartDataSet] else { return }
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< scatterData.dataSetCount
            {
                let dataSet = dataSets[i]
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = chartView.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let shapeSize = dataSet.scatterShapeSize
                let lineHeight = valueFont.lineHeight
                
                _xBounds.set(chart: chartView, dataSet: dataSet, animator: animator)
                
                for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if (!viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        e.y,
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    if dataSet.drawValuesEnabled
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: text,
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - shapeSize - lineHeight),
                            align: .center,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: dataSet.valueTextColorAt(j)]
                        )
                    }
                    
                    if let icon = e.icon, dataSet.drawValuesEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let chartView = chartView,
            let scatterData = chartView.scatterData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = scatterData.getDataSetByIndex(high.dataSetIndex) as? ScatterChartDataSet,
                set.highlightEnabled
                else { continue }
            
            guard let entry = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: set) { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = entry.x // get the x-position
            let y = entry.y * Double(animator.phaseY)
            
            let trans = chartView.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValue(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
}
