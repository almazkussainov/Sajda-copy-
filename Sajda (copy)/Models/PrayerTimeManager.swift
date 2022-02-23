//
//  PrayerTimeManager.swift
//  Sajda (copy)
//
//  Created by Алмаз Кусаинов on 29.01.2022.
//

import Foundation

protocol PrayerTimeManagerDelegate {
    func didUpdateTime(_ prayerTimeManager: PrayerTimeManager, prayerTime: PrayerTimeModel)
    func didFailWithError(error: Error)
    func compareTime(_ prayerTimeManager: PrayerTimeManager, prayerTime: PrayerTimeModel)
}

struct  PrayerTimeManager {
    let prayerTimeURL = "https://api.pray.zone/v2/times/today.json?"
    
    var delegate: PrayerTimeManagerDelegate?
    
    func fetchTime(cityName: String) {
        let URLString = "\(prayerTimeURL)city=\(cityName)&timeformat=1&juristic=1"
        performRequest(with: URLString)
    }
    
    func performRequest(with urlString: String) {
        //1. Create a URL
        
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let prayerTime = self.parseJSON(safeData) {
                        self.delegate?.didUpdateTime(self, prayerTime: prayerTime)
                        self.delegate?.compareTime(self, prayerTime: prayerTime)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
        
    }
    
    func parseJSON(_ prayerData: Data) -> PrayerTimeModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PrayerData.self, from: prayerData)
            let fajrTime = decodedData.results.datetime[0].times.Fajr
            let sunriseTime = decodedData.results.datetime[0].times.Sunrise
            let dhuhrTime = decodedData.results.datetime[0].times.Dhuhr
            let asrTime = decodedData.results.datetime[0].times.Asr
            let maghribTime = decodedData.results.datetime[0].times.Maghrib
            let ishaTime = decodedData.results.datetime[0].times.Isha
            
            let prayerTime = PrayerTimeModel(fajrTime: fajrTime, sunriseTime: sunriseTime, dhuhrTime: dhuhrTime, asrTime: asrTime, maghribTime: maghribTime, ishaTime: ishaTime)
            
            return prayerTime
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
