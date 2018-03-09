//
//  DataAcess.swift
//  article
//
//  Created by Safhone on 3/6/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation


class DataAccess {
    
    static let manager = DataAccess()
    private init() { }
    
    private enum Methods: String {
        case GET    = "GET"
        case POST   = "POST"
        case DELETE = "DELETE"
        case PUT    = "PUT"
        
    }

    private func request(url: URL, method: Methods, body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        
        switch method.rawValue {
        case Methods.GET.rawValue:
            request.httpMethod = method.rawValue
            
        case Methods.POST.rawValue:
            request.httpMethod = method.rawValue
            request.httpBody   = body
            
        case Methods.DELETE.rawValue:
            request.httpMethod = method.rawValue
            
        case Methods.PUT.rawValue:
            request.httpMethod = method.rawValue
            request.httpBody   = body
            
        default:
            break
        }
        
        request.addValue("application/json",                            forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",                            forHTTPHeaderField: "Accept")
        request.addValue("Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",  forHTTPHeaderField: "Authorization")
        
        return request
        
    }
    
    func fetchData<T: Codable>(urlApi: String, atPage: Int, withLimitation: Int, type: T.Type, completion: @escaping ([T]) -> ()) {
    
        let url = URL(string: "\(urlApi)?page=\(atPage)&limit=\(withLimitation)")!
        
        URLSession.shared.dataTask(with: request(url: url, method: .GET, body: nil)) { data, _, _ in
            if let data = data {
                do {
                    let response    = try JSONDecoder().decode(Response<T>.self, from: data)
                    let data        = response.data
                    
                    DispatchQueue.main.async {
                        completion(data)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        
    }
    
    func deleteData(urlApi: String, id: Int) {
        
        let url = URL(string: "\(urlApi)/\(id)")!
        
        URLSession.shared.dataTask(with: request(url: url, method: .DELETE, body: nil)) { data, _, error in
            guard let _ = data, error == nil else {
                if let error = error as NSError? {
                    print(error)
                }
                return
            }
        }.resume()
        
    }
    
    func saveData<T: Codable>(urlApi: String, object: T) {
        
        let data    = try? JSONEncoder().encode(object)
        var request = self.request(url: URL(string: urlApi)!, method: .POST, body: data)
        
        #if DEBUG
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8)!)
        #endif
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                if let error = error as NSError? {
                    print(error)
                }
                return
            }
        }.resume()
        
    }
    
    func updateArticle<T: Codable>(urlApi: String, object: T, id: Int) {
        
        let data    = try? JSONEncoder().encode(object)
        let request = self.request(url: URL(string: "\(urlApi)/\(id)")!, method: .PUT, body: data)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                if let error = error as NSError? {
                    print(error)
                }
                return
            }
        }.resume()
        
    }
    
    func uploadImage(urlApi: String, image: Data, completion: @escaping (String) -> ()) {
        
        struct Upload: Codable {
            var CODE    : String?
            var MESSAGE : String?
            var DATA    : String?
        }
        
        let imageData   = image
        let mimeType    = "image/jpeg"
        let boundary    = "Boundary-\(UUID().uuidString)"
        var formData    = Data()
        
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"FILE\"; filename=\"Image.png\"\r\n".data(using: .utf8)!)
        formData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        formData.append(imageData)
        formData.append("\r\n".data(using: .utf8)!)
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = self.request(url: URL(string: urlApi)!, method: .POST, body: formData)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        URLSession.shared.uploadTask(with: request, from: formData) { data, _, error in
            if error == nil {
                
                #if DEBUG
                    print("Upload Success")
                #endif
                
                do {
                    let response    = try JSONDecoder().decode(Upload.self, from: data!)
                    let data        = response.DATA
                    
                    DispatchQueue.main.async {
                        completion(data!)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
        }.resume()
        
    }
    
}
