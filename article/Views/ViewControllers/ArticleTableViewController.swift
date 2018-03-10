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
        
        articleViewModel?.articleViewModel.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: ArticleTableViewCell.self)) { index, item, cell in
            DispatchQueue.main.async {
                cell.configureCell(articleViewModel: item)
            }
            
        }.disposed(by: self.disposeBag)
        
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
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.gray]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: attributes)
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "News"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(_:)), name: NSNotification.Name("reloadData"), object: nil)
    }

    @objc private func reloadTableView(_ notification: Notification) {
        fetchData(atPage: 1, withLimitation: 15)
        self.increasePage = 1
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchData(atPage: 1, withLimitation: 15)
        self.increasePage = 1
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
            if decelerate && newFetchBool >= 1 && scrollView.contentOffset.y >= self.view.frame.height {
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
