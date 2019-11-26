//
//  KLineViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/24.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class KLineViewController: BaseViewController {

    var chartView: CandleStickChartView  = CandleStickChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCandleStickChart()
        setCandleStickChartStyle()
        updateData()
    }

    //添加K 线图（烛形图）
    func addCandleStickChart(){
        
        let size:CGSize = self.view.frame.size
        chartView.backgroundColor = UIColor.white
        chartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chartView.center = self.view.center
        chartView.delegate = self
        self.view.addSubview(chartView)
    }
    
    func setCandleStickChartStyle(){
        
        // K线图描述
        chartView.chartDescription?.text = "K线图"
        chartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)
        chartView.chartDescription?.textColor = UIColor.red
        
        let legend = chartView.legend
        legend.wordWrapEnabled = true
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.formSize = 10
        legend.form = Legend.Form.line
        
        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bothSided
        xAxis.axisMinimum = 0
        xAxis.granularity = 1
    }
    
    @objc func updateData(){
        
        let entries = (1..<20).map { (i) -> CandleChartDataEntry in
            let range = UInt32(30)
            let val = Double(arc4random_uniform(40) + range)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            //true表示开盘价高于收盘价
            let even = arc4random_uniform(2) % 2 == 0
            return CandleChartDataEntry(x: Double(i),
                                        shadowH: val + high,
                                        shadowL: val - low,
                                        open: even ? val + open : val - open,
                                        close: even ? val - close : val + close)
        }
        
        let chartDataSet1 = CandleChartDataSet(values: entries, label: "图例1")
        chartDataSet1.shadowWidth = 1.5
        chartDataSet1.decreasingFilled = true
        chartDataSet1.increasingFilled = true
        chartDataSet1.setColor(.gray)
        chartDataSet1.shadowColor = .darkGray
        chartDataSet1.decreasingColor = ZHFColor.red
        chartDataSet1.increasingColor = ZHFColor.gray
        chartDataSet1.shadowColorSameAsCandle = true
        //chartDataSet1.showCandleBar = false
        
        let chartData = CandleChartData(dataSets: [chartDataSet1])
        chartView.data = chartData
    }
    
    override func rightBarBtnClicked() {
        self.updateData()
    }
}



extension KLineViewController: ChartViewDelegate{
    //1.点击选中
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        ZHFLog(message: "点击选中")
    }
    //2.没有选中
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        ZHFLog(message: "没有选中")
    }
    //3.捏合放大或缩小
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        ZHFLog(message: "捏合放大或缩小")
    }
    //4.拖拽图表
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        ZHFLog(message: "拖拽图表")
    }
}
