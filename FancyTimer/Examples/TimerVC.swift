//
//  TimerVC.swift
//  FancyTimer
//
//  Created by Sadie Contini on 2/9/18.
//  Copyright © 2018 Sadie Contini. All rights reserved.
//

import AVFoundation
import UIKit

class TimerVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerMinuteLabel: UILabel!
    @IBOutlet weak var timerSecondLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var delegate: TimerVCDelegate?
    
    var timerTitle: String!
    
    var fancyTimer = FancyTimer()
    var startTimerOnLoad = false
    
    class func initWith(title: String,
                        durationSeconds: Int,
                        countDirection: TimerCountDirection,
                        startTimerOnLoad: Bool = false) -> TimerVC {
        
        let storyboard = UIStoryboard(name: "Timer", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier : String(describing: TimerVC.self)) as! TimerVC
        
        // Configure Timer
        vc.fancyTimer.configure(withDurationInSeconds: durationSeconds, countDirection: countDirection)

        vc.timerTitle = title
        vc.startTimerOnLoad = startTimerOnLoad
        
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fancyTimer.delegate = self

        // Update UI
        updateTimerDisplay(time: TimeInterval(fancyTimer.currentSeconds))
        titleLabel.text = timerTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startTimerOnLoad {
            startOrStopTimer()
        }
    }
    
    // MARK: - Update UI
    
    func updateTimerDisplay(time:TimeInterval) {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        timerMinuteLabel.text = String(format:"%02i", minutes)
        timerMinuteLabel.frame.size = timerMinuteLabel.intrinsicContentSize
        timerSecondLabel.text = String(format:"%02i", seconds)
        timerSecondLabel.frame.size = timerSecondLabel.intrinsicContentSize
    }
    
    
    // MARK: - Start and Stop
    
    func startOrStopTimer() {
        if fancyTimer.timer.isValid {
            stopTimer(shouldReset: false)
        } else {
            startTimer()
        }
    }
    
    private func stopTimer(shouldReset: Bool) {
        fancyTimer.stop(shouldReset: shouldReset)
        setStartButton(isStopped: true)
        letPhoneSleep(true)
    }
    
    private func startTimer() {
        fancyTimer.startTimer()
        setStartButton(isStopped: false)
        letPhoneSleep(false)
    }
    
    func letPhoneSleep(_ okToSleep: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !okToSleep
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonWasPressed(_ sender: UIButton) {
        startOrStopTimer()
    }
    
    func setStartButton(isStopped: Bool) {
        // Set title and edge insets to keep ▶︎ and ◼︎ in same place
        if isStopped {
            startButton.setTitle("▶︎",for: .normal)
            startButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 4)
        } else {
            startButton.setTitle("◼︎",for: .normal)
            startButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 7, right: 7)
        }
        startButton.setNeedsDisplay()
    }
    
    @IBAction func resetButtonWasPressed(_ sender: UIButton) {
        // Reset Timer
        fancyTimer.stop(shouldReset: true)
        
        // Reset Main Display
        updateTimerDisplay(time: TimeInterval(fancyTimer.currentSeconds))
        
        // Reset Start Button
        setStartButton(isStopped: true)
    }
    
    @IBAction func close(_ sender: UIButton) {
        // Stop Timer
        fancyTimer.stop(shouldReset: false)
        
        self.dismiss(animated: true) {
            [unowned self] in
            self.delegate?.timerVC(self, didDismiss: self.fancyTimer.currentSeconds)
        }
    }
    
}

// MARK: - FancyTimerDelegate
extension TimerVC: FancyTimerDelegate {
    func fancyTimer(_ fancyTimer: FancyTimer,
                      didUpdateTimer timer: Timer) {
        updateTimerDisplay(time: TimeInterval(fancyTimer.currentSeconds))
    }
}
