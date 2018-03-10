//
//  ArticleViewController.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import UIKit
import SDWebImage

class NewsViewController: UIViewController {

    @IBOutlet weak var articleImageView : UIImageView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var descLabel        : UILabel!
    @IBOutlet weak var dateLabel        : UILabel!
    @IBOutlet weak var scrollView       : UIScrollView!

    var newsTitle       : String?
    var newsImage       : String?
    var newsDescription : String?
    var newsDate        : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: descLabel.bottomAnchor).isActive = true
        
        title = "Article"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let imgURL = URL(string: newsImage!) {
            articleImageView.sd_setImage(with: imgURL, placeholderImage: #imageLiteral(resourceName: "sorry-image-not-available"))
        }
        
        titleLabel.text     = newsTitle
        descLabel.text      = newsDescription
        dateLabel.text      = newsDate
        
    }
    
}
