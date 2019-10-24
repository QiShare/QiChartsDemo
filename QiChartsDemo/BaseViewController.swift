//
//  BaseViewController.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/24.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit

let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenWidth = UIScreen.main.bounds.size.width

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.setNavBar()
    }
    
    func setNavBar() {
        if ((self.navigationController?.topViewController) != nil) && self.navigationController?.viewControllers.first != self {
            let rBarBtn: UIBarButtonItem = UIBarButtonItem.init(title: "刷新", style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightBarBtnClicked))
            self.navigationItem.rightBarButtonItem = rBarBtn
        }
    }
    
    
    @objc public func rightBarBtnClicked() {
        
        
    }
}
