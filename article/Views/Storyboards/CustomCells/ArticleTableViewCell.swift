//
//  ArticleTableViewCell.swift
//  article
//
//  Created by Safhone on 3/5/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet private weak var articleImageView : UIImageView!
    @IBOutlet private weak var articleTitleLabel: UILabel!
    @IBOutlet private weak var articleDateLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(articleViewModel: ArticleViewModel) {
        articleTitleLabel.text  = articleViewModel.title.value
        articleDateLabel.text   = articleViewModel.created_date.value
        if let imgURL = URL(string: (articleViewModel.image.value)) {
            articleImageView.sd_setImage(with: imgURL, placeholderImage: #imageLiteral(resourceName: "sorry-image-not-available"))
        }
    }
    
}
