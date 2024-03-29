//
//  DataRenderer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc(ChartRendererBase)
open class ChartRenderBase: Renderer
{
    @objc public let animator: Animator
    
    @objc public init(animator: Animator, viewPortHandler: ViewPortHandler)
    {
        self.animator = animator

        super.init(viewPortHandler: viewPortHandler)
    }

    @objc open func drawData(context: CGContext)
    {
        fatalError("drawData() cannot be called on DataRenderer")
    }
    
    @objc open func drawValues(context: CGContext)
    {
        fatalError("drawValues() cannot be called on DataRenderer")
    }
    
    @objc open func drawExtras(context: CGContext)
    {
        fatalError("drawExtras() cannot be called on DataRenderer")
    }
    
    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - parameter indices: the highlighted values
    @objc open func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        fatalError("drawHighlighted() cannot be called on DataRenderer")
    }
    
    /// An opportunity for initializing internal buffers used for rendering with a new size.
    /// Since this might do memory allocations, it should only be called if necessary.
    @objc open func initBuffers() { }
    
    @objc open func isDrawingValuesAllowed(chartView: ChartViewBase?) -> Bool
    {
        guard let data = chartView?.data else { return false }
        return data.entryCount < Int(CGFloat(chartView?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }
}
