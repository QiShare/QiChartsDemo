//
//  ScatterChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import QiCharts

class ScatterViewController: BaseViewController {
    
    var chartView: ScatterChartView = ScatterChartView()
    
    var xAxis: XAxis!
    var leftAxis: YAxis!
    let axisMaximum :Double = 100
    lazy var xVals: NSMutableArray = NSMutableArray.init()
    var chartData: ScatterChartData = ScatterChartData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addScatterChartView()
        setBarChartViewXY()
        updataData()
    }
    
    func addScatterChartView(){
        
        let size:CGSize = self.view.frame.size
        chartView.backgroundColor = UIColor.white
        chartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chartView.center = self.view.center
        chartView.delegate = self
        self.view.addSubview(chartView)
        
        //基本样式
        chartView.noDataText = "暂无数据"
        //barChartView.drawValueAboveBarEnabled = true
        
        //交互设置
        //barChartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = true
        chartView.dragDecelerationEnabled = true
        chartView.dragDecelerationFrictionCoef = 0.9
    }
    
    func setBarChartViewXY(){
        
        xAxis = chartView.xAxis
        //xAxis.delegate = self
        xAxis.axisLineWidth = 1.0
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.drawGridLinesEnabled = false
        //设置label间隔，若设置为1，则如果能全部显示，则每个柱形下面都会显示label
        xAxis.labelWidth = 1
        xAxis.axisLineColor = UIColor.black
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = UIColor.darkGray
        
        chartView.rightAxis.enabled = false
        
        // leftAxis的设置（label内容可以用ChartAxisValueFormatter来设置）
        leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = axisMaximum
        leftAxis.forceLabelsEnabled = true
        // 如果forceLabelsEnabled等于true, 则强制绘制制定数量的label
        leftAxis.labelCount = 6
        leftAxis.axisLineWidth = 1.0
        leftAxis.axisLineColor = UIColor.darkGray
        leftAxis.labelPosition = YAxis.LabelPosition.outsideChart
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        //设置虚线样式的网格线(对应的是每条横着的虚线[10.0, 3.0]对应实线和虚线的长度)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineDashLengths = [4.0, 2.0]
        leftAxis.gridColor = UIColor.gray
        leftAxis.gridAntialiasEnabled = true
        leftAxis.spaceTop = 0.15
        
        //设置限制线
        let limitLine : ChartLimitLine = ChartLimitLine.init(limit: Double(axisMaximum * 0.85), label: "限制线")
        limitLine.lineWidth = 1.0
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [5.0, 2.0]
        limitLine.labelPosition = ChartLimitLine.LabelPosition.rightTop
        limitLine.valueTextColor = UIColor.darkText
        limitLine.valueFont = UIFont.systemFont(ofSize: 10)
        leftAxis.addLimitLine(limitLine)
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        //4.描述文字设置
        chartView.chartDescription?.text = "柱形图"
        chartView.chartDescription?.position = CGPoint.init(x: 80, y: 5)
        chartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)
        chartView.chartDescription?.textColor = UIColor.orange
        
        //5.设置类型试图的对齐方式，右上角 (默认左下角)
        let legend = chartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.textColor = UIColor.orange
        legend.font = UIFont.systemFont(ofSize: 11.0)
    }
    
    func updataData(){
        
        let count: Int = 9
        
        let values1 = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(axisMaximum)) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let values2 = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(axisMaximum)) + 3)
            return ChartDataEntry(x: Double(i) + 0.33, y: val)
        }
        
        let set1 = ScatterChartDataSet(values: values1, label: "DS 1")
        set1.setScatterShape(.square)
        set1.setColor(ChartColorTemplates.colorful()[0])
        set1.scatterShapeSize = 8
        
        let set2 = ScatterChartDataSet(values: values2, label: "DS 2")
        set2.setScatterShape(.circle)
        set2.scatterShapeHoleColor = ChartColorTemplates.colorful()[3]
        set2.scatterShapeHoleRadius = 3.5
        set2.setColor(ChartColorTemplates.colorful()[1])
        set2.scatterShapeSize = 8
        
        let data = ScatterChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))

        chartView.data = data
    }
    
    override func rightBarBtnClicked() {
        
        self.updataData()
    }
}


    //MARK:-   <ChartViewDelegate代理方法实现>
extension ScatterViewController :ChartViewDelegate {
    
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
