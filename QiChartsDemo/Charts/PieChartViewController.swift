//
//  PieChartViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/8/7.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class PieChartViewController: UIViewController {

    var chartView:QiPieChartView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "PieChart"
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = []
        
        let size = self.view.frame.size
        chartView = QiPieChartView.init(frame: CGRect.init(x: 15, y: 15, width: size.width - 15 * 2, height: 100))
        chartView?.backgroundColor = .cyan
        self.view.addSubview(chartView)
        
        chartView.sayHello()
    }

}
