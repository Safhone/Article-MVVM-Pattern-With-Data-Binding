//
//  Constant.swift
//  article
//
//  Created by Safhone on 3/6/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


struct ShareManager {
    static let share = ShareManager()
    private init(){ }
    
    struct APIKEY {
        static let ARTICLE      = "http://api-ams.me/v1/api/articles"
        static let UPLOAD_IMAGE = "http://api-ams.me/v1/api/uploadfile/single"
    }
    
}
