//
//  Response.swift
//  article
//
//  Created by Safhone on 3/6/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


struct Response<T: Codable>: Codable {
    
    var CODE    : String?
    var MESSAGE : String?
    var DATA    : [T] = [T]()
    
}
