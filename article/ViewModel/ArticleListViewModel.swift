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
import RxDataSources


internal typealias completionHandler = () -> ()

class ArticleViewModel {
    
    var id: Variable<Int>               = Variable<Int>(0)
    var title: Variable<String>         = Variable<String>("")
    var description: Variable<String>   = Variable<String>("")
    var created_date: Variable<String>  = Variable<String>("")
    var image: Variable<String>         = Variable<String>("")
    
    init() {}

    init(article: Article) {
        self.id.value              = article.id!
        self.title.value           = article.title ?? ""
        self.description.value     = article.description ?? ""
        self.created_date.value    = (article.created_date?.formatDate(getTime: true))!
        self.image.value           = article.image ?? ""
    }
    
    private(set) var imageName: String = ""
    private(set) var articleViewModel: Variable<[ArticleViewModel]> = Variable<[ArticleViewModel]>([])
    var datasource = RxTableViewSectionedAnimatedDataSource<SectionViewModel>(configureCell: { _, _, _, _ in
        fatalError()
    })

    var isValid: Observable<Bool> {
        return Observable.combineLatest(title.asObservable(), description.asObservable()) { title, description in
            title.trimmingCharacters(in: .whitespaces).count > 0 && description.trimmingCharacters(in: .whitespaces).count > 0
        }
    }
    
    func getArticle(atPage: Int, withLimitation: Int, completion: @escaping completionHandler) {
        DataAccess.manager.fetchData(urlApi: ShareManager.APIKEY.ARTICLE, atPage: atPage, withLimitation: withLimitation, type: Article.self) { articles in
            if atPage != 1 {
                let articles = articles?.map(ArticleViewModel.init)
                self.articleViewModel.value += articles!
            } else {
                self.articleViewModel.value = []
                self.articleViewModel.value = (articles?.map(ArticleViewModel.init))!
            }
            completion()
        }
    }
    
    func saveArticle(image: Data, completion: @escaping completionHandler) {
        uploadArticleImage(image: image) {
            let article = Article(id: 0, title: self.title.value, description: self.description.value, created_date: "", image: self.imageName)
            DataAccess.manager.saveData(urlApi: ShareManager.APIKEY.ARTICLE, object: article)
            completion()
        }
    }
    
    func updateArticle(image: Data, id: Int, completion: @escaping completionHandler) {
        uploadArticleImage(image: image) {
            let article = Article(id: 0, title: self.title.value, description: self.description.value, created_date: "", image: self.imageName)
            DataAccess.manager.updateArticle(urlApi: ShareManager.APIKEY.ARTICLE, object: article, id: id)
            completion()
        }
    }
    
    private func uploadArticleImage(image: Data, completion: @escaping completionHandler) {
        DataAccess.manager.uploadImage(urlApi: ShareManager.APIKEY.UPLOAD_IMAGE, image: image) { imageName in
            self.imageName = imageName
            completion()
        }
    }
    
    func deleteArticle(id: Int) {
        DataAccess.manager.deleteData(urlApi: ShareManager.APIKEY.ARTICLE, id: id)
    }
    
    func articleAt(index :Int) -> ArticleViewModel {
        return self.articleViewModel.value[index]
    }
    
    func articleRemoveAt(index: Int) {
        self.articleViewModel.value.remove(at: index)
    }
    
}


struct SectionViewModel {
    var header: String
    var items: [ArticleViewModel]
    
}

extension SectionViewModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ArticleViewModel
    
    var identity: String {
        return header
    }
    
    init(original: SectionViewModel, items: [ArticleViewModel]) {
        self = original
        self.items = items
    }
    
}

extension ArticleViewModel: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return String(id.value)
    }

}

extension ArticleViewModel: Equatable {
    static func ==(lhs: ArticleViewModel, rhs: ArticleViewModel) -> Bool {
        return String(describing: lhs.id) == String(describing: rhs.id)
    }
    
    
}
