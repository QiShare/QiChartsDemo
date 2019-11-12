//
//  ComponentBase.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics


@objc(ChartComponentBase)
open class ComponentBase: NSObject
{
    @objc open var enabled = true
    @objc open var isEnabled: Bool {
        return enabled
        
    }
    
    /// 该组件相对于x轴的偏移量
    @objc open var xOffset = CGFloat(5.0)
    
    /// 该组件相对于y轴的偏移量
    @objc open var yOffset = CGFloat(5.0)
    
    public override init() {
        super.init()
    }

    
}
