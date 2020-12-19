//
//  NewsTableViewCell.swift
//  VkNews
//
//  Created by user184905 on 12/12/20.
//  Copyright © 2020 user184905. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var NewsImage: UIImageView!
    @IBOutlet weak var NewsText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NewsImage = UIImageView(frame: CGRect(x: 40,y: 40,width: 40,height: 40))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
