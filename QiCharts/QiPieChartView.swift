//
//  PieChartView.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/8/9.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit

open class QiPieChartView: UIView {

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.sayHello()
    }
    
    
    open func sayHello() {
        
        print("Hello")
        
        
    }
}
