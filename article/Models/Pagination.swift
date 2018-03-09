//
//  Pagination.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation

class Pagination {
    var page: Int?
    var limit: Int?
    var total_count: Int?
    var total_pages: Int?
    
    init?(dictionary: [String: Any]) {
        guard let page = dictionary["PAGE"] as? Int,
            let limit = dictionary["LIMIT"] as? Int,
            let total_count = dictionary["TOTAL_COUNT"] as? Int,
            let total_pages = dictionary["TOTAL_PAGES"] as? Int else {
                return nil
        }
        
        self.page = page
        self.limit = limit
        self.total_count = total_count
        self.total_pages = total_pages
    }
    
}
