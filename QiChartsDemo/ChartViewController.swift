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
    case ChartType_Line = 2
    case ChartType_KLine = 3
}


class ChartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var titleArr: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QiChartsDemo"
        self.view.backgroundColor = .white
        
        titleArr = NSArray.init(array: ["柱状图", "饼图", "折线图", "K线图"])
        
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
        
        switch chartType {
            
        case .ChartType_Bar:
            
            let barController = BarViewController()
            self.navigationController?.pushViewController(barController, animated: true)
            break
            
        case .ChartType_Pie:
            break
            
        case .ChartType_Line:
            break
            
        case .ChartType_KLine:
            break
            
        default:
            break;
        }
    }
}

