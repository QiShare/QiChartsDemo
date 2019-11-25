//
//  GroupBarViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/11/5.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class GroupBarViewController: BaseViewController {
    
    var barChartView: BarChartView = BarChartView()
    lazy var xVals: NSMutableArray = NSMutableArray.init()
    var data: BarChartData = BarChartData()
    let axisMaximum :Double = 100
    
    var xAxis: XAxis!
    var leftAxis: YAxis!
    
    var years: NSMutableArray = NSMutableArray.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarChartView()
        setBarChartViewXY()
        updataData()
    }
    
    func addBarChartView(){
        
        let size:CGSize = self.view.frame.size
        barChartView.backgroundColor = UIColor.white
        barChartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        barChartView.center = self.view.center
        barChartView.delegate = self
        self.view.addSubview(barChartView)
        
        //基本样式
        barChartView.noDataText = "暂无数据"
        //barChartView.drawValueAboveBarEnabled = true
        
        //交互设置
        //barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        //barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = true
        barChartView.dragDecelerationEnabled = true
        barChartView.dragDecelerationFrictionCoef = 0.9
    }
    
    func setBarChartViewXY(){
        
        xAxis = barChartView.xAxis
        xAxis.delegate = self
        xAxis.axisLineWidth = 1
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.drawGridLinesEnabled = false
        
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = UIColor.black
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 1
        
        barChartView.rightAxis.enabled = false //不绘制右边轴线
        
        // leftAxis的设置（label内容可以用ChartAxisValueFormatter来设置）
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.positivePrefix = "$"  //数字前缀positivePrefix、 后缀positiveSuffix
        leftAxis = barChartView.leftAxis
        leftAxis.valueFormatter = ChartAxisValueFormatter.init(formatter: leftAxisFormatter)
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = axisMaximum
        leftAxis.forceLabelsEnabled = true
        leftAxis.labelCount = 6
        leftAxis.inverted = false
        leftAxis.axisLineWidth = 0.5
        leftAxis.axisLineColor = UIColor.black
        leftAxis.labelPosition = YAxis.LabelPosition.outsideChart
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        leftAxis.drawGridLinesEnabled = true //是否绘制网格线(默认为true)
        leftAxis.gridLineDashLengths = [4.0, 2.0]
        leftAxis.gridColor = UIColor.gray
        leftAxis.gridAntialiasEnabled = true
        leftAxis.spaceTop = 0.15
        //设置限制线
        let limitLine : ChartLimitLine = ChartLimitLine.init(limit: Double(axisMaximum * 0.75), label: "限制线")
        limitLine.lineWidth = 1.0
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [5.0, 2.0]
        limitLine.labelPosition = ChartLimitLine.LabelPosition.rightTop//位置
        limitLine.valueTextColor = UIColor.darkText
        limitLine.valueFont = UIFont.systemFont(ofSize: 10)
        leftAxis.addLimitLine(limitLine)
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        barChartView.chartDescription?.text = "组柱状图"
        barChartView.chartDescription?.position = CGPoint.init(x: 80, y: 5)
        barChartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)
        barChartView.chartDescription?.textColor = UIColor.orange
        
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.textColor = UIColor.orange
        legend.font = UIFont.systemFont(ofSize: 11.0)
    }
    
    @objc func updataData(){
        
        years = ["2015", "2016" , "2017" , "2018" , "2019"]
        let groups = 3
        
        let datasets :NSMutableArray = NSMutableArray.init()
        for i in 0..<groups {
            var dataEntries = [BarChartDataEntry]()
            for j in 0..<years.count {
                let y = arc4random()%UInt32(floor(axisMaximum))
                let entry = BarChartDataEntry(x: Double(j), y: Double(y))
                dataEntries.append(entry)
            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "图例\(i)")
            chartDataSet.colors = [ZHFColor.zhf_randomColor()]
            datasets.add(chartDataSet)
        }
        
        //目前柱状图包括2组立柱
        let chartData = BarChartData(dataSets: datasets as? [ChartDataSet])
        
        //柱子宽度（ (0.2 + 0.03) * 3 + 0.31 = 1.00 -> interval per "group"）
        let groupSpace = 0.31
        let barSpace = 0.03
        let barWidth = 0.2
        
        //设置柱子宽度
        chartData.barWidth = barWidth
         
        //对数据进行分组（不重叠显示）
        chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
         
        //设置X轴范围
        barChartView.xAxis.axisMinimum = Double(0)
        barChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(years.count)
//        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: years as! [String])
        
        //设置柱状图数据
        barChartView.data = chartData
        
        barChartView.animate(yAxisDuration: 1)//展示方式xAxisDuration 和 yAxisDuration两种
        //barChartView.animate(xAxisDuration: 2, yAxisDuration: 2)//展示方式xAxisDuration 和 yAxisDuration两种
    }
    
    override func rightBarBtnClicked() {
        
        self.updataData()
    }
}


//MARK:-   <ChartViewDelegate代理方法实现>
extension GroupBarViewController :ChartViewDelegate, AxisValueFormatterDelegate {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if axis is XAxis {
            if Int(value)>=0 && Int(value)<years.count {
                return self.years[Int(value)] as! String
            }
        }
        return ""
    }
    
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
