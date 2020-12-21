//
//  NewsFeed.swift
//  VkNews
//
//  Created by user184905 on 12/16/20.
//  Copyright © 2020 user184905. All rights reserved.
//

import Foundation
import UIKit

public class NewsFeed{
    
    var ready = false
    let news: NewsFeedStr
    var posts: [Post] = []
    let homeVC: NewNewsViewController
    var images: [UIImage] = [] 
    
    init(pData:Data, pHomeVC: NewNewsViewController){
        var decodedJSON = NewsFeedStr()
        do{
            decodedJSON = try JSONDecoder().decode(NewsFeed.NewsFeedStr.self, from: pData)
        }catch{
            print(JSON(pData))
            print(error)
        }
        news = decodedJSON
        homeVC = pHomeVC
    }
    
    struct NewsFeedStr: Codable{
        var items: [NewsItem]
        var groups: [Group]
        init(pItems: [NewsItem] = [], pGroups: [Group] = [] ){
            self.items = pItems
            self.groups = pGroups
        }
    }
    
    struct NewsItem: Codable{
        var attachments: [Attachment]? = []
        var text: String
        var source_id: Int
    }
    
    struct Group: Codable{
        var id: Int
        var name: String
        var photo_100: URL
    }
    
    struct Attachment: Codable{
        var type: String
        var photo: Photo?
    }
    
    struct Photo: Codable{
        var user_id: Int
        var sizes: [PhotoSize]
    }
    
    struct PhotoSize: Codable{
        var url: URL
        var type: String
        var height: Int
        var width: Int
    }
    
    struct Post{
        var text: String?
        var photos: [URL]?
        var group_name: String
        var group_img: URL
    }
    
    func makePosts()->[Post]{
        var posts: [Post] = []
        for i in news.items{
            posts.append(Post(text: i.text, photos: pickPhotosUrl(pAttachments: i.attachments ?? []), group_name: getGroupName(pNewsItem: i), group_img: getGroupPicture(pNewsItem: i)!))
        }
        return posts
    }
    
    
    func pickPhotosUrl(pAttachments: [Attachment])-> [URL]{
        var photos: [URL] = []
        for i in pAttachments{
            if i.type == "photo"{
                for j in i.photo!.sizes{
                    if j.type == "r"{
                        photos.append(j.url)
                    }
                }
            }
        }
        return photos
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        
    }
    
    func getGroupName(pNewsItem: NewsItem)->String{
        for i in news.groups{
            if (pNewsItem.source_id * -1 == i.id){
                return i.name
            }
        }
        return "NoName"
    }
    
    func getGroupPicture(pNewsItem: NewsItem)->URL?{
        var result:URL
        result = news.groups[0].photo_100
        for i in news.groups{
            if (pNewsItem.source_id * -1 == i.id){
                result = i.photo_100
            }
        }
        return result
    }
    
}
