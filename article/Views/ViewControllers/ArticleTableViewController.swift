//
//  ViewController.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import UIKit
import SDWebImage
import RxCocoa
import RxSwift


class ArticleTableViewController: UITableViewController {

    private var articleViewModel: ArticleViewModel?
    
    private let paginationIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var loadingIndicatorView    = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var increasePage            = 1
    private var newFetchBool            = 0
    private let disposeBag              = DisposeBag()
    private let scrollView              = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.preservesSuperviewLayoutMargins   = false
        tableView.separatorInset                    = UIEdgeInsets.zero
        tableView.layoutMargins                     = UIEdgeInsets.zero
        tableView.tableFooterView                   = UIView()
        tableView.estimatedRowHeight                = 111
        tableView.rowHeight                         = UITableViewAutomaticDimension
        tableView.dataSource                        = nil
        
        articleViewModel = ArticleViewModel()
        
        fetchData(atPage: self.increasePage, withLimitation: 15)

        articleViewModel?.datasource.canEditRowAtIndexPath = { _, _ in
            return true
        }
        
        articleViewModel?.datasource.configureCell = {(datasource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleTableViewCell
            cell.configureCell(articleViewModel: item)
            return cell
        }
        
        articleViewModel?.datasource.titleForHeaderInSection = { datasource, index in
            let section = datasource[index]
            return section.header
        }
        
        if let articleDatasource = articleViewModel?.datasource {
            articleViewModel?.articleViewModel.asObservable().map({ [SectionViewModel(header: "Personal", items: $0)] }).bind(to: tableView.rx.items(dataSource: articleDatasource)).disposed(by: disposeBag)
        }
        
        
//        articleViewModel?.articleViewModel.asDriver().drive(self.tableView.rx.items(cellIdentifier: "Cell", cellType: ArticleTableViewCell.self)) { index, item, cell in
//            DispatchQueue.main.async {
//                cell.configureCell(articleViewModel: item)
//            }
//
//        }.disposed(by: self.disposeBag)
//
//        tableView.rx.didEndDragging.asObservable().subscribe(onNext: { (decelerate) in
//            let bottomEdge = self.scrollView.contentOffset.y + self.scrollView.frame.size.height
//            if (bottomEdge >= self.scrollView.contentSize.height) {
//                if decelerate && self.newFetchBool >= 1 {
//                    self.increasePage += 1
//                    self.tableView.layoutIfNeeded()
//                    self.tableView.tableFooterView              = self.paginationIndicatorView
//                    self.tableView.tableFooterView?.isHidden    = false
//                    self.tableView.tableFooterView?.center      = self.paginationIndicatorView.center
//                    self.paginationIndicatorView.startAnimating()
//                    self.fetchData(atPage: self.increasePage, withLimitation: 15)
//                    self.newFetchBool = 0
//                }else if !decelerate {
//                    self.newFetchBool = 0
//            }
//            }
//        }).disposed(by: self.disposeBag)
//        tableView.delegate?.scrollViewDidEndDragging!(self.scrollView, willDecelerate: false)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            let newsStoryBoard = self?.storyboard?.instantiateViewController(withIdentifier: "newsVC") as! NewsViewController
            newsStoryBoard.newsImage        = self?.getArticleViewModelAt(index: indexPath.row).image.value
            newsStoryBoard.newsTitle        = self?.getArticleViewModelAt(index: indexPath.row).title.value
            newsStoryBoard.newsDescription  = self?.getArticleViewModelAt(index: indexPath.row).description.value
            newsStoryBoard.newsDate         = self?.getArticleViewModelAt(index: indexPath.row).created_date.value
            
            self?.navigationController?.pushViewController(newsStoryBoard, animated: true)
        }).disposed(by: self.disposeBag)
        
        let x = self.view.frame.width / 2
        let y = self.view.frame.height / 2
        loadingIndicatorView.center           = CGPoint(x: x, y: y - 100)
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.startAnimating()
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.gray]
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: attributes)
        tableView.addSubview(refreshControl!)
        
        refreshControl?.rx.controlEvent(.valueChanged).subscribe({ _ in
            self.fetchData(atPage: 1, withLimitation: 15)
            self.increasePage = 1
        }).disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "News"
        
        NotificationCenter.default.rx.notification(Notification.Name("reloadData"), object: nil).bind { notification in
            self.fetchData(atPage: 1, withLimitation: 15)
            self.increasePage = 1
        }.disposed(by: self.disposeBag)
    }
    
    private func fetchData(atPage: Int, withLimitation: Int) {
        articleViewModel?.getArticle(atPage: atPage, withLimitation: withLimitation) {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.loadingIndicatorView.stopAnimating()
                self.paginationIndicatorView.stopAnimating()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(.init(x: 0, y: -116), animated: true)
                }
            }
        }
    }
    
    private func getArticleViewModelAt(index: Int) -> ArticleViewModel {
        return (articleViewModel?.articleAt(index: index))!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        newFetchBool = 0
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        newFetchBool += 1
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
            let alert = UIAlertController(title: "Are you sure to delete?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                DispatchQueue.main.async {
                    self.articleViewModel?.deleteArticle(id: self.getArticleViewModelAt(index: indexPath.row).id.value)
                    self.articleViewModel?.articleRemoveAt(index: indexPath.row)
                    self.tableView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, index) in
            if let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "addVC") as? AddArticleViewController {
                addViewController.newsID            = self.getArticleViewModelAt(index: indexPath.row).id.value
                addViewController.newsTitle         = self.getArticleViewModelAt(index: indexPath.row).title.value
                addViewController.newsDescription   = self.getArticleViewModelAt(index: indexPath.row).description.value
                addViewController.newsImage         = self.getArticleViewModelAt(index: indexPath.row).image.value
                addViewController.isUpdate          = true
                self.navigationController?.pushViewController(addViewController, animated: true)
            }
        }
        return [delete, edit]
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if (bottomEdge >= scrollView.contentSize.height) {
            if decelerate && newFetchBool >= 1 {
                self.increasePage += 1
                self.tableView.layoutIfNeeded()
                self.tableView.tableFooterView              = paginationIndicatorView
                self.tableView.tableFooterView?.isHidden    = false
                self.tableView.tableFooterView?.center      = paginationIndicatorView.center
                self.paginationIndicatorView.startAnimating()
                fetchData(atPage: increasePage, withLimitation: 15)
                self.newFetchBool = 0
            }
        } else if !decelerate {
            newFetchBool = 0
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
