//
//  NewsViewController.swift
//  VkNews
//
//  Created by user184905 on 12/7/20.
//  Copyright © 2020 user184905. All rights reserved.
//

import UIKit
import SwiftyVK
import VkNews

class NewsViewController: UITableViewController{
    var newsfeed: NewsFeed? = nil
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
    
        super.viewDidLoad()
        VK.API.NewsFeed.get([.filters: "post",
                             .count: "10",
                             .sourceIds:"groups"])
            .onSuccess {result in
                self.newsfeed = NewsFeed(pData: result, pHomeVC: self)
                
            }.onError{result in print(result)}.send()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200
    }

    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if ((newsfeed?.ready) != nil){
            return newsfeed!.posts.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else { fatalError()  }
        if((newsfeed?.ready) != nil){   
            let post = newsfeed?.posts[indexPath.row]
            if(post != nil){
                cell.NewsImage.image = post!.group_img
                cell.NewsText.text = post!.group_name
            }
            
        }
        return cell
    }
}
