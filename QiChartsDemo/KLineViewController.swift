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

        //1.添加K 线图（烛形图)
        addCandleStickChart()
        //2. 基本样式
        setCandleStickChartViewStyle()
        //3.添加（刷新数据）
        updataData()
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
    
    func setCandleStickChartViewStyle(){
        
        //K 线图（烛形图）描述
        chartView.chartDescription?.text = "K 线图（烛形图）描述"
        chartView.chartDescription?.position = CGPoint.init(x: chartView.frame.width - 30, y:chartView.frame.height - 20)//位置（及在bubbleChartView的中心点）
        chartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)//大小
        chartView.chartDescription?.textColor = UIColor.red
        
        //图例
        let l = chartView.legend
        l.wordWrapEnabled = false //显示图例
        l.horizontalAlignment = .left //居左
        l.verticalAlignment = .bottom //放在底部
        l.orientation = .horizontal //水平排布
        l.drawInside = false // 图例在外
        l.formSize = 10 //（图例大小）默认是8
        l.form = Legend.Form.circle//图例头部样式
        //矩形：.square（默认值） 圆形：.circle   横线：.line  无：.none 空：.empty（与 .none 一样都不显示头部，但不同的是 empty 头部仍然会占一个位置)
        //Y轴右侧线
        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        //Y轴左侧线
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        //X轴
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bothSided //分布在两边外部
        xAxis.axisMinimum = 0 //最小刻度值
        xAxis.granularity = 1 //最小间隔
    }
    
    @objc func updataData(){
        //第一组烛形图的10条随机数据
        let entries = (0..<10).map { (i) -> CandleChartDataEntry in
            let val = Double(arc4random_uniform(40) + 10)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            let even = arc4random_uniform(2) % 2 == 0 //true表示开盘价高于收盘价
            
            return CandleChartDataEntry(x: Double(i),
                                        shadowH: val + high,
                                        shadowL: val - low,
                                        open: even ? val + open : val - open,
                                        close: even ? val - close : val + close)
        }
        
        let chartDataSet1 = CandleChartDataSet(values: entries, label: "图例1")
        chartDataSet1.shadowWidth = 2 //柱线（烛心线）颜色
        chartDataSet1.decreasingFilled = false //开盘高于收盘则使用空心矩形
        chartDataSet1.increasingFilled = true //开盘低于收盘则使用实心矩形
        chartDataSet1.setColor(.gray) //整体设置颜色
        chartDataSet1.shadowColor = .darkGray //柱线（烛心线）颜色
        chartDataSet1.decreasingColor = ZHFColor.red //实心颜色
        chartDataSet1.increasingColor = ZHFColor.gray //空心颜色
        chartDataSet1.shadowColorSameAsCandle = true//竖线的颜色与方框颜色一样
        //chartDataSet1.showCandleBar = false //不显示方块
        //目前烛形图包括1组数据
        let chartData = CandleChartData(dataSets: [chartDataSet1])
        
        //设置烛形图数据
        chartView.data = chartData
    }
    
    override func rightBarBtnClicked() {
        self.updataData()
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
