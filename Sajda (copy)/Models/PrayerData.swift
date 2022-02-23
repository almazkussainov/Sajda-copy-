//
//  prayerData.swift
//  Sajda (copy)
//
//  Created by Алмаз Кусаинов on 29.01.2022.
//

import Foundation

struct PrayerData: Codable {
    let results: Results
}

struct Results: Codable {
    let location: Location
    let datetime: [DateTime]
}

struct Location: Codable {
    let city: String
}

struct DateTime: Codable {
    let times: Times
}


struct Times: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
