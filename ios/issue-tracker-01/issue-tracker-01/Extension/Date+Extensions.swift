//
//  Date+Extensions.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/16/24.
//

import Foundation

extension Date {
    static func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: dateString)
    }
    
    func timeAgoDisplay() -> String {
        var calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        print("Days: \(components.day ?? 0), Hours: \(components.hour ?? 0), Minutes: \(components.minute ?? 0)")
        if let day = components.day, day > 0 {
            return "\(day)일 전"
        }
        
        if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        }
        
        if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        }
        
        return "방금 전"
    }
}
