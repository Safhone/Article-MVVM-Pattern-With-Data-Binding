//
//  Extension.swift
//  article
//
//  Created by Safhone Oung on 3/8/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


extension String {
    
    func subString(startIndex: Int, endIndex: Int) -> String {
        let end                 = (endIndex - self.count) + 1
        let indexStartOfText    = self.index(self.startIndex, offsetBy: startIndex)
        let indexEndOfText      = self.index(self.endIndex, offsetBy: end)
        let substring           = self[indexStartOfText..<indexEndOfText]
        
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
