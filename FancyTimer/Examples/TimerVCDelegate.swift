//
//  TimerVCDelegate.swift
//  FancyTimer
//
//  Created by sadie on 2/9/18.
//  Copyright © 2018 tumbleweed. All rights reserved.
//

import UIKit

protocol TimerVCDelegate {
    func timerVC(_ timerVC: UIViewController,
                 didDismiss elapsedSeconds: Int)
}
