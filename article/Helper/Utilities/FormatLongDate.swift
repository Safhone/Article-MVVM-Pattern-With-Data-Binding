//
//  FormatLongDate.swift
//  DENH TLAI
//
//  Created by Safhone Oung on 1/30/18.
//  Copyright © 2018 Chhaileng Peng. All rights reserved.
//

import Foundation

final class FormatLongDate {
    
    // Mark: For End Date
    static open func customDate(date: Int) -> String {
        let dateFormatter = DateFormatter()
        var dateVar: Date?
        var formatted: String?
        
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        
        dateVar = Date(timeIntervalSince1970: (Double(date) / 1000.0))
        formatted = dateFormatter.string(from: dateVar!)
        
        let splitDate = formatted?.components(separatedBy: " ")
        let fullDateTime: String
        
        // Mark: 24 hours
        if splitDate?.count == 4 {
            let day   = splitDate![0]
            let month = splitDate![1]
            let year  = splitDate![2]
            let hour  = splitDate![3]
            fullDateTime = day + " " + month + " " + year + " " + hour
        } else { // Mark: 12 hours
            let day   = splitDate![0]
            let month = splitDate![1]
            let year  = splitDate![2]
            let hour  = splitDate![3]
            let am_pm = splitDate![4]
            fullDateTime = day + " " + month + " " + year + " " + hour + " " + am_pm
        }
        
        return fullDateTime
    }
    
}

extension String {
    func subString(startIndex: Int, endIndex: Int) -> String {
        let end = (endIndex - self.count) + 1
        let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
        let indexEndOfText = self.index(self.endIndex, offsetBy: end)
        let substring = self[indexStartOfText..<indexEndOfText]
        return String(substring)
    }
    
    func formatDate(getTime: Bool) -> String {
        if getTime {
            return "\(self.subString(startIndex: 6, endIndex: 7))-\(self.subString(startIndex: 4, endIndex: 5))-\(self.subString(startIndex: 0, endIndex: 3)) \(self.subString(startIndex: 8, endIndex: 9)):\(self.subString(startIndex: 10, endIndex: 11))"
        } else {
            return "\(self.subString(startIndex: 6, endIndex: 7))-\(self.subString(startIndex: 4, endIndex: 5))-\(self.subString(startIndex: 0, endIndex: 3))"
        }
    }
}
