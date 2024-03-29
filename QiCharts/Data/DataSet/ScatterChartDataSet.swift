//
//  ScatterChartDataSet.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

open class ScatterChartDataSet: LineScatterCandleRadarChartDataSet
{
    
    @objc(ScatterShape)
    public enum Shape: Int
    {
        case square
        case circle
        case triangle
        case cross
        case x
        case chevronUp
        case chevronDown
    }
    
    /// The size the scatter shape will have
    open var scatterShapeSize = CGFloat(10.0)
    
    /// The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// **default**: 0.0
    open var scatterShapeHoleRadius: CGFloat = 0.0
    
    /// Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    open var scatterShapeHoleColor: NSUIColor? = nil
    
    /// Sets the ScatterShape this DataSet should be drawn with.
    /// This will search for an available IShapeRenderer and set this renderer for the DataSet
    @objc open func setScatterShape(_ shape: Shape)
    {
        self.shapeRenderer = ScatterChartDataSet.renderer(forShape: shape)
    }
    
    /// The IShapeRenderer responsible for rendering this DataSet.
    /// This can also be used to set a custom IShapeRenderer aside from the default ones.
    /// **default**: `SquareShapeRenderer`
    open var shapeRenderer: IShapeRenderer? = SquareShapeRenderer()
    
    @objc open class func renderer(forShape shape: Shape) -> IShapeRenderer
    {
        switch shape
        {
        case .square: return SquareShapeRenderer()
        case .circle: return CircleShapeRenderer()
        case .triangle: return TriangleShapeRenderer()
        case .cross: return CrossShapeRenderer()
        case .x: return XShapeRenderer()
        case .chevronUp: return ChevronUpShapeRenderer()
        case .chevronDown: return ChevronDownShapeRenderer()
        }
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShapeHoleRadius = scatterShapeHoleRadius
        copy.scatterShapeHoleColor = scatterShapeHoleColor
        copy.shapeRenderer = shapeRenderer
        return copy
    }
}
