//
//  Renderer.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc(ChartRenderer)
open class Renderer: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    @objc public let viewPortHandler: ViewPortHandler

    @objc public init(viewPortHandler: ViewPortHandler)
    {
        self.viewPortHandler = viewPortHandler
        super.init()
    }
}
