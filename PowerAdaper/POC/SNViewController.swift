//
//  TestViewController.swift
//  PowerAdaper
//
//  Created by sunil.kumar1 on 5/6/20.
//  Copyright © 2020 sunil.kumar1. All rights reserved.
//

import UIKit
import PowerAdapter

class SNViewController: PAViewController {
    @IBOutlet var segmentContainer: PASegmentViewContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentContainer.bindParent(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentContainer.setSegment(PASegment(SNView(), SNController()))
    }

}
