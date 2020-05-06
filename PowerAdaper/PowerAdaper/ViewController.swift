//
//  ViewController.swift
//  PowerAdaper
//
//  Created by sunil.kumar1 on 5/6/20.
//  Copyright © 2020 sunil.kumar1. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func btnAction(_ sender: UIButton) {
        let testViewController = TestViewController(nibName: "TestViewController", bundle: nil)
        self.navigationController?.pushViewController(testViewController, animated: true)
    }
}

