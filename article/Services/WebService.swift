//
//  WebService.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation

class WebService {
    
    func loadArticle(atPage: Int, withLimitation: Int, completion: @escaping ([Article]) -> ()) {
        DataAccess.manager.fetchData()
        let url = URL(string: "http://api-ams.me/v1/api/articles?page=\(atPage)&limit=\(withLimitation)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json",                           forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",                           forHTTPHeaderField: "Accept")
        request.addValue("Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response<Article>.self, from: data)
                    let article = response.DATA
                    DispatchQueue.main.async {
                        completion(article)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }.resume()

    }
    
}
