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
        chartView.noDataText = "暂无数据"//没有数据时的显示
        //barChartView.drawValueAboveBarEnabled = true//数值显示是否在条柱上面
        
        //交互设置
        //barChartView.scaleXEnabled = false//取消X轴缩放
        chartView.scaleYEnabled = false//取消Y轴缩放
        chartView.doubleTapToZoomEnabled = false//取消双击是否缩放
        chartView.pinchZoomEnabled = false//取消XY轴是否同时缩放
        chartView.dragEnabled = true //启用拖拽图表
        chartView.dragDecelerationEnabled = true //拖拽后是否有惯性效果
        chartView.dragDecelerationFrictionCoef = 0.9 //拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    }
    
    func setBarChartViewXY(){
        //1.X轴样式设置（对应界面显示的--->0月到7月）
        xAxis = chartView.xAxis
        //xAxis.delegate = self //重写代理方法  设置x轴数据
        xAxis.axisLineWidth = 0.5 //设置X轴线宽
        xAxis.labelPosition = XAxis.LabelPosition.bottom //X轴（5种位置显示，根据需求进行设置）
        xAxis.drawGridLinesEnabled = false//不绘制网格
        xAxis.labelWidth = 1 //设置label间隔，若设置为1，则如果能全部显示，则每个柱形下面都会显示label
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)//x轴数值字体大小
        xAxis.labelTextColor = UIColor.brown//数值字体颜色
    
        //2.Y轴左样式设置（对应界面显示的--->0 到 100）
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.positivePrefix = "$"  //数字前缀positivePrefix、 后缀positiveSuffix
        leftAxis = chartView.leftAxis
        leftAxis.valueFormatter = ChartAxisValueFormatter.init(formatter: leftAxisFormatter)
        leftAxis.axisMinimum = 0     //最小值
        leftAxis.axisMaximum = axisMaximum   //最大值
        leftAxis.forceLabelsEnabled = true //不强制绘制制定数量的label
        leftAxis.labelCount = 6    //Y轴label数量，数值不一定，如果forceLabelsEnabled等于true, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.inverted = false   //是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 0.5   //Y轴线宽
        leftAxis.axisLineColor = UIColor.black   //Y轴颜色
        leftAxis.labelPosition = YAxis.LabelPosition.outsideChart//坐标数值的位置
        leftAxis.labelTextColor = UIColor.brown//坐标数值字体颜色
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10) //y轴字体大小
        //设置虚线样式的网格线(对应的是每条横着的虚线[10.0, 3.0]对应实线和虚线的长度)
        leftAxis.drawGridLinesEnabled = true //是否绘制网格线(默认为true)
        leftAxis.gridLineDashLengths = [5.0, 3.0]
        leftAxis.gridColor = UIColor.gray //网格线颜色
        leftAxis.gridAntialiasEnabled = true//开启抗锯齿
        leftAxis.spaceTop = 0.15//最大值到顶部的范围比
        
        //设置限制线
        let limitLine : ChartLimitLine = ChartLimitLine.init(limit: Double(axisMaximum * 0.85), label: "限制线")
        limitLine.lineWidth = 1.0
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [5.0, 2.0]
        limitLine.labelPosition = ChartLimitLine.LabelPosition.rightTop//位置
        limitLine.valueTextColor = UIColor.darkText
        limitLine.valueFont = UIFont.systemFont(ofSize: 10)
        leftAxis.addLimitLine(limitLine)
        leftAxis.drawLimitLinesBehindDataEnabled = true //设置限制线在柱线图后面（默认在前）
        
        //3.Y轴右样式设置（如若设置可参考左样式）
        chartView.rightAxis.enabled = false //不绘制右边轴线
        
        //4.描述文字设置
        chartView.chartDescription?.text = "柱形图"//右下角的description文字样式 不设置的话会有默认数据
        chartView.chartDescription?.position = CGPoint.init(x: 80, y: 5)//位置（及在barChartView的中心点）
        chartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)//大小
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
    
    override func rightBarBtnClicked() {
        
        self.updataData()
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
