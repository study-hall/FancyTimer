//
//  FancyTimer.swift
//  FancyTimer
//
//  Created by Sadie Contini on 2/9/18.
//  Copyright © 2018 tumbleweed. All rights reserved.
//

import Foundation

enum TimerCountDirection: String {
    case up, down
}

protocol FancyTimerDelegate {
    func fancyTimer(_ fancyTimer: FancyTimer,
                      didUpdateTimer timer: Timer)
}

// by default, only able to show up to 00:59:99
let maxSecondsVisibleOnTimer = 3599

class FancyTimer {
    
    var timer = Timer()

    var delegate: FancyTimerDelegate?
    
    var startDate: Date?
    
    var isPaused = false
    
    // starting seconds should be set to
    // 0 to count up
    // >0 to count down
    var startingSeconds = 0
    var originalStartingSeconds = 0 {
        didSet {
            startingSeconds = originalStartingSeconds
        }
    }
    
    var countDirection = TimerCountDirection.up
    var currentSeconds = 0 {
        didSet {
            print(currentSeconds)
        }
    }
    var endingSeconds: Int = maxSecondsVisibleOnTimer
    
    func configure(withDurationInSeconds durationSeconds: Int,
                countDirection direction: TimerCountDirection = .up) {
        
        countDirection = direction
        
        switch direction {
        case .up:
            originalStartingSeconds = 0
            endingSeconds = durationSeconds
            currentSeconds = 0
        case .down:
            originalStartingSeconds = durationSeconds
            endingSeconds = 0
            currentSeconds = durationSeconds
        }
    }
    
    // Start timer counting (from where it left off)
    func startTimer() {
        if !(timer.isValid) {
            if startDate == nil || isPaused == true {
                startDate = Date()
                if isPaused == true {
                    startingSeconds = currentSeconds
                    isPaused = false
                }
            }
            timer = Timer.scheduledTimer(timeInterval: 1, // seconds
                target: self,
                selector: (#selector(updateTimer)),
                userInfo: nil,
                repeats: true)
        }
    }
    
    func stop(shouldReset: Bool) {
        timer.invalidate()
        if shouldReset {
            startDate = nil
            currentSeconds = originalStartingSeconds
            isPaused = false
        } else {
            isPaused = true
        }
    }
    
    @objc func updateTimer() {
        count()
        if isFinished() == true {
            timer.invalidate() // time's up
        }
        delegate?.fancyTimer(self, didUpdateTimer: timer)
    }
    
    func isFinished() -> Bool {
        if countDirection == .up {
            return (currentSeconds >= maxSecondsVisibleOnTimer || currentSeconds >= endingSeconds)
        } else {
            return currentSeconds <= endingSeconds
        }
    }
    
    // Returns true if current seconds
    // are between start and finish.
    // Note: Timer could be paused.
    func isStartedAndNotFinished() -> Bool {
        return startingSeconds != currentSeconds &&
            !isFinished()
    }
    
    // Set timer to the difference between
    // now() and the startTime
    private func count() {
        print("before count: \(currentSeconds)")
        guard let start = startDate else {
            return
        }
        
        let secondsElapsed = NSInteger(Date().timeIntervalSince(start))
        switch countDirection {
        case .up:
            currentSeconds = startingSeconds + secondsElapsed
        case .down:
            if secondsElapsed > startingSeconds {
                // don't count below 0
                currentSeconds = 0
            } else {
                currentSeconds = startingSeconds - secondsElapsed
            }
        }
        print("after count: \(currentSeconds)")
    }
}


