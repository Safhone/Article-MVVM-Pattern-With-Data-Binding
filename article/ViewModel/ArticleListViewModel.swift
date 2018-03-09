//
//  ArticleListViewModel.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


internal typealias completionHandler = () -> ()

class ArticleViewModel {
    
    var id: Variable<Int>               = Variable<Int>(0)
    var title: Variable<String>         = Variable<String>("")
    var description: Variable<String>   = Variable<String>("")
    var created_date: Variable<String>  = Variable<String>("")
    var image: Variable<String>         = Variable<String>("")
    
    private(set) var imageName: String                      = ""
    private(set) var articleViewModel: [ArticleViewModel]   = [ArticleViewModel]()
    
    init() { }

    init(article: Article) {
        self.id.value              = article.id!
        self.title.value           = article.title ?? ""
        self.description.value     = article.description ?? ""
        self.created_date.value    = (article.created_date?.formatDate(getTime: true))!
        self.image.value           = article.image!
    }
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(title.asObservable(), description.asObservable()) { title, description in
            title.trimmingCharacters(in: .whitespaces).count > 0 && description.trimmingCharacters(in: .whitespaces).count > 0
        }
    }
    
    func getArticle(atPage: Int, withLimitation: Int, completion: @escaping completionHandler) {
        DataAccess.manager.fetchData(urlApi: ShareManager.APIKEY.ARTICLE, atPage: atPage, withLimitation: withLimitation, type: Article.self) { articles in
            if atPage != 1 {
                let articles = articles.map(ArticleViewModel.init)
                self.articleViewModel += articles
            } else {
                self.articleViewModel = []
                self.articleViewModel = articles.map(ArticleViewModel.init)
            }
            completion()
        }
    }
    
    func saveArticle(image: String) {
        let article = Article(id: 0, title: title.value, description: description.value, created_date: "", image: image)
        DataAccess.manager.saveData(urlApi: ShareManager.APIKEY.ARTICLE, object: article)
    }
    
    func updateArticle(image: String, id: Int) {
        let article = Article(id: 0, title: title.value, description: description.value, created_date: "", image: image)
        DataAccess.manager.updateArticle(urlApi: ShareManager.APIKEY.ARTICLE, object: article, id: id)
    }
    
    func uploadArticleImage(image: Data, completion: @escaping completionHandler) {
        DataAccess.manager.uploadImage(urlApi: ShareManager.APIKEY.UPLOAD_IMAGE, image: image) { imageName in
            self.imageName = imageName
            completion()
        }
    }
    
    func deleteArticle(id: Int) {
        DataAccess.manager.deleteData(urlApi: ShareManager.APIKEY.ARTICLE, id: id)
    }
    
    func articleAt(index :Int) -> ArticleViewModel {
        return self.articleViewModel[index]
    }
    
    func articleRemoveAt(index: Int) {
        self.articleViewModel.remove(at: index)
    }
    
}
