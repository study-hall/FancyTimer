//
//  ViewController.swift
//  FancyTimer
//
//  Created by Sadie Contini on 2/9/18.
//  Copyright © 2018 Sadie Contini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func countDownButtonPressed(_ sender: UIButton) {
        let vc = TimerVC.initWith(title: sender.currentTitle ?? "", durationSeconds: 120, countDirection: .down, startTimerOnLoad: false)
        vc.delegate = self
        present(vc, animated: true) {}
    }
    
    @IBAction func countUpButtonPressed(_ sender: UIButton) {
        let vc = TimerVC.initWith(title: sender.currentTitle ?? "", durationSeconds: maxSecondsVisibleOnTimer, countDirection: .up, startTimerOnLoad: false)
        vc.delegate = self
        present(vc, animated: true) {}
    }
    
    @IBAction func countWithCountInButtonPressed(_ sender: UIButton) {
        let vc = TimerWithCountInVC.initWith(title: sender.currentTitle ?? "", durationSeconds: 180, countDirection: .up, startTimerOnLoad: true)
        vc.delegate = self
        present(vc, animated: true) {}
    }
}

extension ViewController: TimerVCDelegate {
    func timerVC(_ timerVC: UIViewController, didDismiss elapsedSeconds: Int) {
        //
    }
}

