//
//  TimerWithCountInVC.swift
//  FancyTimer
//
//  Created by sadie on 2/9/18.
//  Copyright © 2018 tumbleweed. All rights reserved.
//

import AVFoundation
import UIKit

class TimerWithCountInVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerMinuteLabel: UILabel!
    @IBOutlet weak var timerSecondLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countInLabel: UILabel!
    
    var delegate: TimerVCDelegate?
    
    var timerTitle: String!
    
    var countInTimer = FancyTimer()
    var countInSeconds = 3
    var mainTimer = FancyTimer()
    var startTimerOnLoad = false
    
    class func initWith(title: String,
                        durationSeconds: Int,
                        countDirection: TimerCountDirection,
                        startTimerOnLoad: Bool = false) -> TimerWithCountInVC {
        let storyboard = UIStoryboard(name: "Timer", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier : String(describing: TimerWithCountInVC.self)) as! TimerWithCountInVC
        
        vc.timerTitle = title
        vc.startTimerOnLoad = startTimerOnLoad
        
        // Configure Timers
        vc.mainTimer.configure(withDurationInSeconds: durationSeconds, countDirection: countDirection)
        
        vc.countInTimer.configure(withDurationInSeconds: vc.countInSeconds, countDirection: .down)
        
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTimer.delegate = self
        countInTimer.delegate = self
        
        // Update UI
        updateMainTimerDisplay(time: TimeInterval(mainTimer.currentSeconds))
        titleLabel.text = timerTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startTimerOnLoad {
            startOrStopTimers()
        }
    }
    
    // MARK: - Update UI
    
    func updateMainTimerDisplay(time:TimeInterval) {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        timerMinuteLabel.text = String(format:"%02i", minutes)
        timerMinuteLabel.frame.size = timerMinuteLabel.intrinsicContentSize
        timerSecondLabel.text = String(format:"%02i", seconds)
        timerSecondLabel.frame.size = timerSecondLabel.intrinsicContentSize
    }
    
    func updateCountInDisplay(for timer: FancyTimer) {
        countInLabel.text = "count-in: \(timer.currentSeconds)"
        let countInLabelColor = (timer.isStartedAndNotFinished() == true) ? UIColor.red : UIColor.white
        countInLabel.textColor = countInLabelColor
    }
    
    
    // MARK: - Start and Stop
    
    func startOrStopTimers() {
        if countInTimer.isFinished() == true {
            if mainTimer.timer.isValid {
                stopMainTimer(shouldReset: false)
            } else {
                startMainTimer()
            }
        } else {
            startCountinTimer()
        }
    }
    
    private func stopMainTimer(shouldReset: Bool) {
        mainTimer.stop(shouldReset: shouldReset)
        setStartButton(isStopped: true)
        letPhoneSleep(true)
    }
    
    private func startMainTimer() {
        mainTimer.startTimer()
        setStartButton(isStopped: false)
        letPhoneSleep(false)
    }
    
    private func startCountinTimer() {
        countInLabel.textColor = .red
        countInTimer.startTimer()
        setStartButton(isStopped: false)
        letPhoneSleep(false)
    }
    
    func letPhoneSleep(_ okToSleep: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !okToSleep
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonWasPressed(_ sender: UIButton) {
        startOrStopTimers()
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
        // Reset Timers
        mainTimer.stop(shouldReset: true)
        countInTimer.stop(shouldReset: true)
        
        // Reset Main Display
        updateMainTimerDisplay(time: TimeInterval(mainTimer.currentSeconds))
        
        // Reset Count-In Display
        updateCountInDisplay(for: countInTimer)
        
        // Reset Start Button
        setStartButton(isStopped: true)
    }
    
    @IBAction func close(_ sender: UIButton) {
        // Stop Timers
        mainTimer.stop(shouldReset: false)
        countInTimer.stop(shouldReset: false)
        
        self.dismiss(animated: true) {
            [unowned self] in
            self.delegate?.timerVC(self, didDismiss: self.mainTimer.currentSeconds)
        }
    }
    
}

// MARK: - FancyTimerDelegate
extension TimerWithCountInVC: FancyTimerDelegate {
    func fancyTimer(_ fancyTimer: FancyTimer,
                      didUpdateTimer timer: Timer) {
        if mainTimer.timer == fancyTimer.timer {
            updateMainTimerDisplay(time: TimeInterval(fancyTimer.currentSeconds))
        } else if countInTimer.timer == fancyTimer.timer {
            let countInTimer = fancyTimer
            updateCountInDisplay(for: countInTimer)
            if countInTimer.isFinished() {
                countInLabel.textColor = .white
                mainTimer.startTimer()
            }
        }
    }
}

