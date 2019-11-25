//
//  LineViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/24.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class LineViewController: BaseViewController {

    var circleColors :[UIColor] = [UIColor]()
    var chartView: LineChartView  = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加折线
        addLineChart()
        //设置交互样式
        setLineChartStyle()
        //设置限制线（可设置多根）
        setlimitLine()
        //添加（刷新数据）
        updataData()
    }
    
    func addLineChart(){
        
        let size:CGSize = self.view.frame.size
        chartView.backgroundColor = UIColor.white
        chartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chartView.center = self.view.center
        chartView.delegate = self
        self.view.addSubview(chartView)
    }
    
    func setLineChartStyle(){
        
        chartView.scaleYEnabled = false
        chartView.dragEnabled = true
        chartView.dragDecelerationEnabled = true
        chartView.dragDecelerationFrictionCoef = 0.9
        
        chartView.noDataText = "暂无数据"
        
        chartView.chartDescription?.text = "折线图描述"
        chartView.chartDescription?.position = CGPoint.init(x: chartView.frame.width - 30, y:chartView.frame.height - 20)//位置（及在lineChartView的中心点）
        chartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)//大小
        chartView.chartDescription?.textColor = UIColor.red
        
        chartView.legend.textColor = ZHFColor.purple
        chartView.legend.formSize = 10
        chartView.legend.form = Legend.Form.line
        
        //轴线宽、颜色、刻度、间隔
        chartView.xAxis.axisLineWidth = 1.0
        chartView.xAxis.axisLineColor = .black
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = 10
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .black
        chartView.xAxis.labelFont = .systemFont(ofSize: 13)
        
        //网格线
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.gridColor = .gray
        chartView.xAxis.gridLineWidth = 0.5
        chartView.xAxis.gridLineDashLengths = [4, 2]
        
        chartView.rightAxis.enabled = false

        chartView.leftAxis.enabled = true
        chartView.leftAxis.axisLineWidth = 1.0
        chartView.leftAxis.labelPosition = .outsideChart
    }
    
    func setlimitLine(){
        
        let limitLine1 = ChartLimitLine(limit: 85, label: "优秀")
        limitLine1.lineDashLengths = [4, 2]
        limitLine1.lineColor = ZHFColor.green
        limitLine1.lineWidth = 1.5
        chartView.leftAxis.addLimitLine(limitLine1)
        
        let limitLine2 = ChartLimitLine(limit: 60, label: "合格")
        limitLine2.lineDashLengths = [4, 2]
        limitLine2.lineColor = ZHFColor.red
        limitLine2.lineWidth = 1.5
        chartView.leftAxis.addLimitLine(limitLine2)
        
        chartView.leftAxis.drawLimitLinesBehindDataEnabled = true
    }
    
    
    @objc func updataData(){
        
        // 第一条
        var dataEntries1 = [ChartDataEntry]()
        for i in 0..<20 {
            let y = 50 - arc4random() % 50
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            dataEntries1.append(entry)
            circleColors.append(ZHFColor.blue)
        }
        // 设置折线
        let chartDataSet1 = LineChartDataSet(values: dataEntries1, label: "chartDataSet1")
        chartDataSet1.setColor(ZHFColor.blue)
        chartDataSet1.lineWidth = 2.0
        //贝塞尔曲线（默认是折线 .linear .stepped .cubicBezier .horizontalBezier）
        chartDataSet1.mode = .horizontalBezier
        // 设置折点
        chartDataSet1.circleColors = circleColors
        chartDataSet1.circleHoleColor = ZHFColor.yellow
        chartDataSet1.circleRadius = 3
        chartDataSet1.circleHoleRadius = 2
        // 设置折线上的文字（可通过ChartValueFormatter设置文字格式）
        chartDataSet1.drawValuesEnabled = true
        chartDataSet1.valueColors = [.blue]
        chartDataSet1.valueFont = .systemFont(ofSize: 9)
        // 渐变色填充
        chartDataSet1.drawFilledEnabled = true
        let gradientColors = [UIColor.blue.cgColor, UIColor.white.cgColor] as CFArray
        let colorLocations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: gradientColors, locations: colorLocations)
        chartDataSet1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        
        
        // 第二条
        var dataEntries2 = [ChartDataEntry]()
        for i in 0..<20 {
            let y = 50 + arc4random() % 50
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            dataEntries2.append(entry)
        }
        let chartDataSet2 = LineChartDataSet(values: dataEntries2, label: "chartDataSet2")
        chartDataSet2.setColor(ZHFColor.gray)
        chartDataSet2.lineWidth = 2
        
        let chartData = LineChartData(dataSets: [chartDataSet1, chartDataSet2])
        
        chartView.animate(xAxisDuration: 1)
        chartView.data = chartData
    }
    
    override func rightBarBtnClicked() {
        self.updataData()
    }
}

//MARK:-   ChartViewDelegate
extension LineViewController: ChartViewDelegate{
    //1.点击选中
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        ZHFLog(message: "点击选中")
        //将选中的数据点的颜色改成黄色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let values = chartDataSet.values
        let index = values.firstIndex(where: {$0.x == highlight.x})  //获取索引
        chartDataSet.circleColors = circleColors //还原
        chartDataSet.circleColors[index!] = .orange
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        ////显示该点的MarkerView标签(不同形式)
        //self.showMarkerView(value: "\(entry.y)")
        self.showBalloonMarkerView(value: "\(entry.y)")
    }
    //2.没有选中
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        ZHFLog(message: "取消选中")
        //还原所有点的颜色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        chartDataSet.circleColors =  circleColors
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
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
//MARK:-   MarkerView标签
extension LineViewController{
    //显示MarkerView标签
    func showMarkerView(value:String){
        let marker = MarkerView(frame: CGRect(x: 20, y: 20, width: 80, height: 20))
        marker.chartView = self.chartView
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        label.text = "数据：\(value)"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        marker.addSubview(label)
        self.chartView.marker = marker
    }
    //显示BalloonMarkerView标签
    func showBalloonMarkerView(value:String){
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = self.chartView
        marker.chartView = self.chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        marker.setLabel("数据：\(value)")
        self.chartView.marker = marker
    }
}
