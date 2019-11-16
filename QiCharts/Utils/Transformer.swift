//
//  Transformer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

/// Transformer class that contains all matrices and is responsible for transforming values into pixels on the screen and backwards.
@objc(ChartTransformer)
open class Transformer: NSObject
{
    /// 整个图表（viewPort）对应的矩阵（带默认值）
    internal var _matrixValueToPx = CGAffineTransform.identity

    /// 矩阵偏移量（带默认值）
    internal var _matrixOffset = CGAffineTransform.identity

    /// 当前视口设置的信息，如偏移、缩放和平移级别等
    internal var _viewPortHandler: ViewPortHandler

    @objc public init(viewPortHandler: ViewPortHandler)
    {
        _viewPortHandler = viewPortHandler
    }

    /// 初始化，并根据图表大小和偏移量计算比例因子
    @objc open func prepareMatrixValuePx(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
    {
        var scaleX = (_viewPortHandler.contentWidth / deltaX)
        var scaleY = (_viewPortHandler.contentHeight / deltaY)
        
        if CGFloat.infinity == scaleX
        {
            scaleX = 0.0
        }
        if CGFloat.infinity == scaleY
        {
            scaleY = 0.0
        }

        // setup all matrices
        _matrixValueToPx = CGAffineTransform.identity
        _matrixValueToPx = _matrixValueToPx.scaledBy(x: scaleX, y: -scaleY)
        _matrixValueToPx = _matrixValueToPx.translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }
    
    /// 初始化
    @objc open func prepareMatrixOffset(inverted: Bool)
    {
        if !inverted
        {
            _matrixOffset = CGAffineTransform(translationX: _viewPortHandler.offsetLeft, y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransform(scaleX: 1.0, y: -1.0)
            _matrixOffset = _matrixOffset.translatedBy(x: _viewPortHandler.offsetLeft, y: -_viewPortHandler.offsetTop)
        }
    }
    
    open func pointValuesToPixel(_ points: inout [CGPoint])
    {
        let trans = valueToPixelMatrix
        for i in 0 ..< points.count
        {
            points[i] = points[i].applying(trans)
        }
    }
    
    open func pointValueToPixel(_ point: inout CGPoint)
    {
        point = point.applying(valueToPixelMatrix)
    }
    
    @objc open func pixelForValues(x: Double, y: Double) -> CGPoint
    {
        return CGPoint(x: x, y: y).applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    open func rectValueToPixel(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// 在图表上transfer给定的区域，有 animation phases.
    open func rectValueToPixel(_ r: inout CGRect, phaseY: Double)
    {
        // multiply the height of the rect with the phase
        var bottom = r.origin.y + r.size.height
        bottom *= CGFloat(phaseY)
        let top = r.origin.y * CGFloat(phaseY)
        r.size.height = bottom - top
        r.origin.y = top

        r = r.applying(valueToPixelMatrix)
    }
    
    /// 在图表上transfer给定的区域
    open func rectValueToPixelHorizontal(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// 在图表上transfer给定的接触点，有 animation phases.
    open func rectValueToPixelHorizontal(_ r: inout CGRect, phaseY: Double)
    {
        // multiply the height of the rect with the phase
        let left = r.origin.x * CGFloat(phaseY)
        let right = (r.origin.x + r.size.width) * CGFloat(phaseY)
        r.size.width = right - left
        r.origin.x = left
        
        r = r.applying(valueToPixelMatrix)
    }

    /// 在图表上transfer给定的区域数组
    open func rectValuesToPixel(_ rects: inout [CGRect])
    {
        let trans = valueToPixelMatrix
        
        for i in 0 ..< rects.count
        {
            rects[i] = rects[i].applying(trans)
        }
    }
    
    /// 在图表上transfer给定的接触点数组（像素数组）
    open func pixelsToValues(_ pixels: inout [CGPoint])
    {
        let trans = pixelToValueMatrix
        
        for i in 0 ..< pixels.count
        {
            pixels[i] = pixels[i].applying(trans)
        }
    }
    
    /// 在图表上transfer给定的接触点
    open func pixelToValues(_ pixel: inout CGPoint)
    {
        pixel = pixel.applying(pixelToValueMatrix)
    }
    
    /// 在图表上transfer给定的像素坐标
    @objc open func valueForTouchPoint(_ point: CGPoint) -> CGPoint
    {
        return point.applying(pixelToValueMatrix)
    }
    
    /// 在图表上transfer给定的像素坐标
    @objc open func valueForTouchPoint(x: CGFloat, y: CGFloat) -> CGPoint
    {
        return CGPoint(x: x, y: y).applying(pixelToValueMatrix)
    }
    
    /// 将 整个_viewPortHandler.transfer 与 绘制区域偏移量transform 叠加
    @objc open var valueToPixelMatrix: CGAffineTransform
    {
        return _matrixValueToPx.concatenating(_viewPortHandler.touchMatrix).concatenating(_matrixOffset)
    }
    
    /// 矩阵反转
    @objc open var pixelToValueMatrix: CGAffineTransform
    {
        return valueToPixelMatrix.inverted()
    }
}
