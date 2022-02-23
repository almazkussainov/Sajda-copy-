//
//  ViewController.swift
//  Sajda (copy)
//
//  Created by Алмаз Кусаинов on 28.01.2022.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fajrTime: UILabel!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var dhuhrTime: UILabel!
    @IBOutlet weak var asrTime: UILabel!
    @IBOutlet weak var maghribTime: UILabel!
    @IBOutlet weak var ishaTime: UILabel!
    @IBOutlet weak var namazTable: UIView!
    @IBOutlet weak var currentNamazLabel: UILabel!
    @IBOutlet weak var currentNamazTime: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nextNamazLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var prayerTimeManager = PrayerTimeManager()
    var timer = Timer()
    
    var targetDate: Date?
    var labelUpdateTimer: Timer?
    var timeLeftFormatter: DateComponentsFormatter?
    
    var timeInterval: Double?
    
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        namazTable.layer.cornerRadius = 10
        
        let city = "Astana"
        prayerTimeManager.fetchTime(cityName: city)
        
        prayerTimeManager.delegate = self
        
        locationLabel.text = city
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.prayerTimeManager.fetchTime(cityName: city)
        })
        
        weekDayLabel.text = Date().dayOfWeek()
        dateLabel.text = self.getCurrentDate()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swiped() {
        UISelectionFeedbackGenerator().selectionChanged()
        if timeLabel.isHidden {
            namazTable.isHidden = true
            UIView.transition(with: timeLabel, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.timeLabel.isHidden = false
            })
            UIView.transition(with: nextNamazLabel, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.nextNamazLabel.isHidden = false
            })
        } else {
            UIView.transition(with: namazTable, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.namazTable.isHidden = false
            })
            timeLabel.isHidden = true
            nextNamazLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prayerTimeManager.fetchTime(cityName: "Astana")
    }
}

extension ViewController: PrayerTimeManagerDelegate {
    func didUpdateTime(_ prayerTimeManager: PrayerTimeManager, prayerTime: PrayerTimeModel) {
        DispatchQueue.main.async {
            self.fajrTime.text = prayerTime.fajrTime
            self.sunriseTime.text = prayerTime.sunriseTime
            self.dhuhrTime.text = prayerTime.dhuhrTime
            self.asrTime.text = prayerTime.asrTime
            self.maghribTime.text = prayerTime.maghribTime
            self.ishaTime.text = prayerTime.ishaTime
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
    func compareTime(_ prayerTimeManager: PrayerTimeManager, prayerTime: PrayerTimeModel) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timeString = formatter.string(from: Date())
        
        let fajr = formatter.date(from: prayerTime.fajrTime)
        let sunrise = formatter.date(from: prayerTime.sunriseTime)
        let dhuhr = formatter.date(from: prayerTime.dhuhrTime)
        let asr = formatter.date(from: prayerTime.asrTime)
        let maghrib = formatter.date(from: prayerTime.maghribTime)
        let isha = formatter.date(from: prayerTime.ishaTime)
        
        let secondTime = formatter.date(from: timeString)
        
        DispatchQueue.main.async {
            if isha?.compare(secondTime!) == .orderedAscending || isha?.compare(secondTime!) == .orderedSame {
                self.ishaTime.textColor = .green
                self.maghribTime.textColor = .white
                self.fajrTime.textColor = .white
                self.sunriseTime.textColor = .white
                self.dhuhrTime.textColor = .white
                self.asrTime.textColor = .white
                self.currentNamazTime.text = self.fajrTime.text
                self.currentNamazLabel.text = "Fajr"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.fajrTime.text
                self.nextNamazLabel.text = "Fajr"
            } else if maghrib?.compare(secondTime!) == .orderedAscending || maghrib?.compare(secondTime!) == .orderedSame {
                self.maghribTime.textColor = .green
                self.asrTime.textColor = .white
                self.fajrTime.textColor = .white
                self.sunriseTime.textColor = .white
                self.dhuhrTime.textColor = .white
                self.ishaTime.textColor = .white
                self.currentNamazTime.text = self.ishaTime.text
                self.currentNamazLabel.text = "Isha"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.ishaTime.text
                self.nextNamazLabel.text = "Isha"
            } else if asr?.compare(secondTime!) == .orderedAscending || asr?.compare(secondTime!) == .orderedSame {
                self.asrTime.textColor = .green
                self.dhuhrTime.textColor = .white
                self.maghribTime.textColor = .white
                self.fajrTime.textColor = .white
                self.sunriseTime.textColor = .white
                self.ishaTime.textColor = .white
                self.currentNamazTime.text = self.maghribTime.text
                self.currentNamazLabel.text = "Maghrib"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.maghribTime.text
                self.nextNamazLabel.text = "Maghrib"
            } else if dhuhr?.compare(secondTime!) == .orderedAscending || dhuhr?.compare(secondTime!) == .orderedSame {
                self.dhuhrTime.textColor = .green
                self.sunriseTime.textColor = .white
                self.maghribTime.textColor = .white
                self.fajrTime.textColor = .white
                self.ishaTime.textColor = .white
                self.asrTime.textColor = .white
                self.currentNamazTime.text = self.asrTime.text
                self.currentNamazLabel.text = "Asr"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.asrTime.text
                self.nextNamazLabel.text = "Asr"
            } else if sunrise?.compare(secondTime!) == .orderedAscending || sunrise?.compare(secondTime!) == .orderedSame {
                self.sunriseTime.textColor = .green
                self.maghribTime.textColor = .white
                self.fajrTime.textColor = .white
                self.ishaTime.textColor = .white
                self.dhuhrTime.textColor = .white
                self.asrTime.textColor = .white
                self.currentNamazTime.text = self.dhuhrTime.text
                self.currentNamazLabel.text = "Dhuhr"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.dhuhrTime.text
                self.nextNamazLabel.text = "Dhuhr"
            } else if fajr?.compare(secondTime!) == .orderedAscending || fajr?.compare(secondTime!) == .orderedSame {
                self.fajrTime.textColor = .green
                self.maghribTime.textColor = .white
                self.ishaTime.textColor = .white
                self.sunriseTime.textColor = .white
                self.dhuhrTime.textColor = .white
                self.asrTime.textColor = .white
                self.currentNamazTime.text = self.sunriseTime.text
                self.currentNamazLabel.text = "Sunrise"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.sunriseTime.text
                self.nextNamazLabel.text = "Sunrise"
            } else if secondTime?.compare(fajr!) == .orderedAscending || secondTime?.compare(fajr!) == .orderedSame {
                self.ishaTime.textColor = .green
                self.maghribTime.textColor = .white
                self.fajrTime.textColor = .white
                self.sunriseTime.textColor = .white
                self.dhuhrTime.textColor = .white
                self.asrTime.textColor = .white
                self.currentNamazTime.text = self.fajrTime.text
                self.currentNamazLabel.text = "Fajr"
                self.currentNamazTime.textColor = .systemBlue
                self.currentNamazLabel.textColor = .systemBlue
                self.timeLabel.text = self.fajrTime.text
                self.nextNamazLabel.text = "Fajr"
            }
        }
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension ViewController {
    func getCurrentDate() -> String {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        
        // get the date time String from the date object
        return formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
    }
}

