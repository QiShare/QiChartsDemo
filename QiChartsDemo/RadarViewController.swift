//
//  RadarViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/24.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit
import QiCharts

class RadarViewController: BaseViewController {

    var radarChartView: RadarChartView  = RadarChartView()
    var data: RadarChartData = RadarChartData()
    let axisMaximum :Double = 100
    lazy var xVals: NSMutableArray = NSMutableArray.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRadarChart()
        setRadarChartViewStyle()
        updateData()
    }
   
    
    func addRadarChart(){
        
        let size:CGSize = self.view.frame.size
        radarChartView.backgroundColor = UIColor.white
        radarChartView.frame.size = CGSize.init(width: size.width - 20, height: size.height - 20)
        radarChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        radarChartView.center = self.view.center
        radarChartView.delegate = self
        self.view.addSubview(radarChartView)
    }
    
    func setRadarChartViewStyle(){
        //雷达图描述
        radarChartView.rotationEnabled = true //是否允许转动
        radarChartView.highlightPerTapEnabled = true //是否能被选中
        radarChartView.webLineWidth = 0.75
        radarChartView.webColor = ZHFColor.black
        radarChartView.innerWebLineWidth = 0.375
        radarChartView.innerWebColor = ZHFColor.black
        
        let xAxis: XAxis = radarChartView.xAxis
        xAxis.labelPosition = XAxis.LabelPosition.topInside
        // xAxis.delegate = self
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = ZHFColor.black
        
        let yAxis: YAxis = radarChartView.yAxis
        yAxis.drawLabelsEnabled = false
        yAxis.axisMaximum = axisMaximum
        yAxis.axisMinimum = 0
        yAxis.labelCount = 8
        yAxis.labelFont = UIFont.systemFont(ofSize: 10)
        yAxis.labelTextColor = ZHFColor.brown
       
        //雷达图图例
        radarChartView.chartDescription?.text = "雷达图示例"
        radarChartView.chartDescription?.font = UIFont.systemFont(ofSize: 10)
        radarChartView.chartDescription?.textColor = ZHFColor.zhf33_titleTextColor
        radarChartView.chartDescription?.position = CGPoint.init(x: 80, y: 5)//位置（及在radarChartView的中心点）
        //图例在雷达图中的位置(右上角)
        radarChartView.legend.horizontalAlignment = Legend.HorizontalAlignment.right
        radarChartView.legend.verticalAlignment = Legend.VerticalAlignment.top
        radarChartView.legend.orientation = Legend.Orientation.horizontal
        radarChartView.legend.formSize = 10;
        radarChartView.legend.maxSizePercent = 1
        radarChartView.legend.formToTextSpace = 5
        radarChartView.legend.font = UIFont.systemFont(ofSize: 10)
        radarChartView.legend.textColor = ZHFColor.gray
        radarChartView.legend.form = Legend.Form.circle
    }
    
    func updateData() {
        
        let count = 12
        //对应Y轴上面需要显示的数据
        let yVals: NSMutableArray  = NSMutableArray.init()
        for _ in 0 ..< count {
            let val: Double = Double(arc4random() % 80 + 20)
            let entry:RadarChartDataEntry = RadarChartDataEntry.init(value: val)
            yVals.add(entry)
        }
        //创建RadarChartDataSet对象，其中包含有Y轴数据信息
        let set1: RadarChartDataSet = RadarChartDataSet.init(values: yVals as? [ChartDataEntry], label: "各月份收入示意图")
        set1.lineWidth = 1.5
        set1.setColor(ZHFColor.orange)
        set1.drawFilledEnabled = true
        set1.fillColor = ZHFColor.orange
        set1.fillAlpha = 0.3
        set1.drawValuesEnabled = true
        set1.highlightEnabled = true
        set1.valueFont = UIFont.systemFont(ofSize: 10)
        set1.valueTextColor = ZHFColor.darkGray
        let dataSets: NSMutableArray  = NSMutableArray.init()
        dataSets.add(set1)
        
        let data:  RadarChartData = RadarChartData.init(dataSets: dataSets as? [ChartDataSet])
        radarChartView.data = data
        
        radarChartView.animate(yAxisDuration: 1)
    }
    
    override func rightBarBtnClicked() {
        self.updateData()
    }
}
//MARK:-   <ChartViewDelegate代理方法实现>
extension RadarViewController :ChartViewDelegate, AxisValueFormatterDelegate {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Int(value) > self.xVals.count - 1 {
             return self.xVals[Int(value - 1)] as! String
        }
        else{
             return self.xVals[Int(value)] as! String
        }
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
