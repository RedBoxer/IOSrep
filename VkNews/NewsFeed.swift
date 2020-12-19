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
    struct NewsItem: Codable{
        var attachments: [Attachment]?
        var text: String
        var source_id: Int
    }
    var ready = false
    let news: NewsFeedStr
    var posts: [Post] = []
    let homeVC: NewsViewController
    var images: [UIImage] = [] 
    
    init(pData:Data, pHomeVC: NewsViewController){
        var decodedJSON = NewsFeedStr()
        do{
            decodedJSON = try JSONDecoder().decode(NewsFeed.NewsFeedStr.self, from: pData)
        }catch{
            print(JSON(pData))
            print(error)
        }
        news = decodedJSON
        homeVC = pHomeVC
        DispatchQueue.global(qos: .userInitiated).async{
            self.makePosts()
        }
    }
    
    struct NewsFeedStr: Codable{
        var items: [NewsItem]
        var groups: [Group]
        init(pItems: [NewsItem] = [], pGroups: [Group] = [] ){
            self.items = pItems
            self.groups = pGroups
        }
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
        var photos: [UIImage]?
        var group_name: String
        var group_img: UIImage
    }
    
    func makePosts(){
        var result: [Post] = []
        var text: String
        var photos: [URL] = []
        var images: [UIImage] = []
        var groupImg: UIImage
        let downloadGroupS = DispatchGroup()
        var count: Int = 0
        let downloadGroup = DispatchGroup()
        for i in news.items{
            print("Downloading ")
            if (i.attachments != nil){
                photos = pickPhotosUrl(pAttachments: i.attachments!)
                    for j in photos{
                        downloadGroupS.enter()
                        URLSession.shared.dataTask(with: j, completionHandler: {data, response, error in
                            guard let data = data, error == nil else { return }
                            print(response?.suggestedFilename ?? j.lastPathComponent)
                            print("Download Finished")
                            DispatchQueue.main.async() { [weak self] in
                                images.append(UIImage(data: data)!)
                                count+=1
                            }}).resume()
                        downloadGroupS.leave()
                    }
                    downloadGroup.enter()
                    URLSession.shared.dataTask(with: j, completionHandler: {data, response, error in
                            guard let data = data, error == nil else { return }
                            print(response?.suggestedFilename ?? j.lastPathComponent)
                            print("Group Download Finished")
                            DispatchQueue.main.async() { [weak self] in
                                groupImg = UIImage(data: data)
                            }}).resume()
                    text = i.text
                    downloadGroup.leave()
                    downloadGroup.wait()
                    result.append(Post(text: text, photos: images , group_name: getGroupName(pNewsItem: i), group_img: group_img))
                    images = []
                }
            }
        while(count<news.items.count){}
        downloadGroupS.notify(queue: DispatchQueue.main){
            print("Newsfeed is ready")
            print("s")
            self.ready = true
            self.posts = result
            self.homeVC.tableView.reloadData()
        }
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
    
    func downloadPhotos(pPhotos: [URL]) -> [UIImage]{
        var result: [UIImage] = []
        
        return result;
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
    
    func getGroupPicture(pNewsItem: NewsItem)->URL{
        var result: URL
        for i in news.groups{
            if (pNewsItem.source_id * -1 == i.id){
                print("Group Download started")
                /*getData(from: i.photo_100) { data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? i.photo_100.lastPathComponent)
                    print("Group Download Finished")
                    DispatchQueue.main.async() { [weak self] in
                        result = UIImage(data: data) ?? UIImage()
                    }
                }*/
                result = i.photo_100
            }
        }
        return result
    }
    
}
