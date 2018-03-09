//
//  Article.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


struct Article: Codable {
    
    var id          : Int?
    var title       : String?
    var description : String?
    var created_date: String?
    var image       : String?
    
    private enum CodingKeys: String, CodingKey {
        case id             = "ID"
        case title          = "TITLE"
        case description    = "DESCRIPTION"
        case created_date   = "CREATED_DATE"
        case image          = "IMAGE"
    }
    
    init(id: Int, title: String, description: String, created_date: String, image: String) {
        self.id             = id
        self.title          = title
        self.description    = description
        self.created_date   = created_date
        self.image          = image

    }
    
}
