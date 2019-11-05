//
//  ViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit

enum ChartType:Int {
    case ChartType_Bar = 0
    case ChartType_Pie = 1
    case ChartType_Radar = 2
    case ChartType_KLine = 3
    case ChartType_Line = 4
    case ChartType_GroupBar = 5
}


class ChartViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var titleArr: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QiChartsDemo"
        
        titleArr = NSArray.init(array: ["柱状图", "饼图", "雷达图", "K线图", "折线图", "组柱状图"])
        
        tableView = .init(frame: self.view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        self.view.addSubview(tableView)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        let title = titleArr![indexPath.row]
        cell.textLabel?.text = title as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chartType = ChartType(rawValue: indexPath.row)
        var chartController:BaseViewController = BaseViewController()
        let title: NSString = titleArr![chartType!.rawValue] as! NSString
        
        switch chartType {
            
            case .ChartType_Bar:
                chartController = BarViewController()
                break
            
            case .ChartType_Pie:
                chartController = PieViewController()
                break
            
            case .ChartType_Radar:
                chartController = RadarViewController()
                break
            
            case .ChartType_KLine:
                chartController = KLineViewController()
                break
            
            case .ChartType_Line:
                chartController = LineViewController()
                break
            
            case .ChartType_GroupBar:
                chartController = GroupBarViewController()
                break
            
            default:
                break;
        }
        
        chartController.title = title as String
        self.navigationController?.pushViewController(chartController, animated: true)
    }
}

