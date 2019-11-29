//
//  BarViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/15.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class BarViewController: BaseViewController {
    
    var barChartView: BarChartView = BarChartView()
    lazy var xVals: NSMutableArray = NSMutableArray.init()
    var data: BarChartData = BarChartData()
    let axisMaximum :Double = 100
    
    var xAxis: XAxis!
    var leftAxis: YAxis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarChartView()
        setBarChartStyle()
        updateData()
    }
    
    func addBarChartView() {
        
        let size:CGSize = self.view.frame.size
        barChartView.backgroundColor = UIColor.white
        barChartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        barChartView.center = self.view.center
        barChartView.delegate = self
        self.view.addSubview(barChartView)
    }
    
    func setBarChartStyle() {
        
        barChartView.noDataText = "暂无数据"
        barChartView.scaleYEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = true
        barChartView.dragDecelerationEnabled = true
        barChartView.dragDecelerationFrictionCoef = 0.9
        
        xAxis = barChartView.xAxis
        xAxis.delegate = self
        xAxis.axisLineWidth = 1.0
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelWidth = 1
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = UIColor.black
        xAxis.axisLineColor = .black
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.positivePrefix = "$"
        leftAxis = barChartView.leftAxis
        leftAxis.valueFormatter = ChartAxisValueFormatter.init(formatter: leftAxisFormatter)
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = axisMaximum
        // 强制绘制leftAxisn标签数量
        leftAxis.forceLabelsEnabled = true
        leftAxis.labelCount = 6
        leftAxis.axisLineWidth = 0.5
        leftAxis.axisLineColor = UIColor.black
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        // 虚线设置
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineDashLengths = [5.0, 3.0]
        leftAxis.gridColor = UIColor.gray
        leftAxis.gridAntialiasEnabled = true
        // 最大值到顶部的范围比
        leftAxis.spaceTop = 0.15
        
        /// 设置限制线
        let limitLine : ChartLimitLine = ChartLimitLine.init(limit: Double(axisMaximum * 0.7), label: "限制线")
        limitLine.lineWidth = 1.0
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [5.0, 2.0]
        limitLine.labelPosition = ChartLimitLine.LabelPosition.rightTop//位置
        limitLine.valueTextColor = UIColor.darkText
        limitLine.valueFont = UIFont.systemFont(ofSize: 10)
        
        leftAxis.addLimitLine(limitLine)
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        /// y轴右样式设置（如若设置可参考左样式）
        barChartView.rightAxis.enabled = false //不绘制右边轴线
        
        /// 描述文字设置
        barChartView.chartDescription?.text = "柱形图"//右下角的description文字样式 不设置的话会有默认数据
        barChartView.chartDescription?.position = CGPoint.init(x: 80, y: 5)//位置（及在barChartView的中心点）
        barChartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)//大小
        barChartView.chartDescription?.textColor = UIColor.orange
        
        /// 设置类型试图的对齐方式，右上角 (默认左下角)
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.textColor = UIColor.orange
        legend.font = UIFont.systemFont(ofSize: 11.0)
    }
    
    @objc func updateData(){
        
        /// 对应x轴上面需要显示的数据
        let count = 8
        let x1Vals: NSMutableArray  = NSMutableArray.init()
        for i in 0 ..< count {
            /// x轴字体展示
            x1Vals.add("201\(i)")
            self.xVals = x1Vals
        }
        
        
         /// 对应Y轴上面需要显示的数据
        let yVals: NSMutableArray  = NSMutableArray.init()
        for i in 0 ..< count {
            let val: Double = Double(arc4random_uniform(UInt32(axisMaximum)))
            let entry:BarChartDataEntry  = BarChartDataEntry.init(x:  Double(i), y: Double(val))
            yVals.add(entry)
        }
        /// 创建BarChartDataSet对象，其中包含有Y轴数据信息，以及可以设置柱形样式
        let set1: BarChartDataSet = BarChartDataSet.init(values: yVals as? [ChartDataEntry], label: "信息")
        set1.barBorderWidth = 0.2 //边线宽
        set1.drawValuesEnabled = true //是否在柱形图上面显示数值
        set1.highlightEnabled = true //点击选中柱形图是否有高亮效果，（单击空白处取消选中）
        
        /// 设置柱形图颜色(是一个循环，例如：你设置5个颜色，你设置8个柱形，后三个对应的颜色是该设置中的前三个，依次类推)
        set1.setColors(UIColor.gray,ZHFColor.green,ZHFColor.yellow,ZHFColor.zhf_randomColor(),ZHFColor.zhf_randomColor())
      //  set1.setColors(ChartColorTemplates.material(), alpha: 1)
      //  set1.setColor(ZHFColor.gray)//颜色一致
        
        
        
        let dataSets: NSMutableArray  = NSMutableArray.init()
        dataSets.add(set1)
        
        
        
        /// 创建BarChartData对象, 此对象就是barChartView需要最终数据对象
        let data: BarChartData = BarChartData.init(dataSets: dataSets as? [ChartDataSet])
        data.barWidth = 0.7  //默认是0.85  （介于0-1之间）
        data.setValueFont(UIFont.systemFont(ofSize: 10))
        data.setValueTextColor(UIColor.orange)
        let formatter: NumberFormatter = NumberFormatter.init()
        formatter.numberStyle = NumberFormatter.Style.currency//自定义数据显示格式  小数点形式(可以尝试不同看效果)
        let forma :ChartValueFormatter = ChartValueFormatter.init(formatter: formatter)
        data.setValueFormatter(forma)
        barChartView.data = data
        
        barChartView.animate(yAxisDuration: 1)//展示方式xAxisDuration 和 yAxisDuration两种
       //  barChartView.animate(xAxisDuration: 2, yAxisDuration: 2)//展示方式xAxisDuration 和 yAxisDuration两种
    }
    
    override func rightBarBtnClicked() {
        
        self.updateData()
    }
}


//MARK:-   <ChartViewDelegate代理方法实现>
extension BarViewController :ChartViewDelegate, AxisValueFormatterDelegate {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return self.xVals[Int(value)] as! String
    }
    /// 1.点击选中
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        ZHFLog(message: "点击选中")
    }
    /// 2.没有选中
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
         ZHFLog(message: "没有选中")
    }
    /// 3.捏合放大或缩小
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        ZHFLog(message: "捏合放大或缩小")
    }
    /// 4.拖拽图表
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        ZHFLog(message: "拖拽图表")
    }
}
