//
//  Response.swift
//  article
//
//  Created by Safhone on 3/6/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


struct Response<T: Codable>: Codable {
    
    var code    : String?
    var message : String?
    var data    : [T] = [T]()
    
    private enum CodingKeys: String, CodingKey {
        case code       = "CODE"
        case message    = "MESSAGE"
        case data       = "DATA"
    }
    
}
