//
//  NewNewsViewController.swift
//  VkNews
//
//  Created by user184905 on 12/21/20.
//  Copyright © 2020 user184905. All rights reserved.
//

import UIKit
//import VkNews
import SwiftyVK

class NewNewsViewController: UIViewController {
    @IBOutlet var holderView: UIView!
    let scrollView = UIScrollView()
    var newsfeed: NewsFeed? = nil
    var posts: [NewsFeed.Post] = []
    var isLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
               // Do any additional setup after loading the view.
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLoaded{
        VK.API.NewsFeed.get([.filters: "post",
                             .count: "100",
                             .sourceIds:"groups"])
                             .onSuccess {result in
                                self.newsfeed = NewsFeed(pData: result, pHomeVC: self)
                                self.posts = self.newsfeed!.makePosts()
                                DispatchQueue.main.async {
                                    self.configure()
                                }
                                
                            }.onError{result in print(result)}.send()
        }
    }
        
    
    private func configure(){
        //set up scrollview
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        var titles: [String] = []
        for i in posts{
            titles.append(i.group_name)
        }
        for x in 0..<posts.count{
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y:0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 110, height: 120))
            let group_img = UIImageView(frame: CGRect(x: pageView.frame.size.width-110, y: 10, width: 100, height: 120))
            var imageView = UIImageView(frame: CGRect(x: 10, y: 10+120+10, width: pageView.frame.size.width - 20, height: pageView.frame.size.height-60-130-15))
            if (posts[x].text != ""){
                
                let text = UILabel(frame: CGRect(x: 10, y: 130, width: pageView.frame.size.width-10, height: 20))
                
                text.textAlignment = .left
                text.numberOfLines = 1
                text.text = posts[x].text
                while(text.isTruncated() /*&& text.numberOfLines < 5*/){
                    text.numberOfLines += 2
                    text.frame.size.height += 40
                }
                imageView = UIImageView(frame: CGRect(x: 10, y: 10+120+CGFloat(text.frame.size.height) , width: pageView.frame.size.width - 20, height: pageView.frame.size.height-60-130-15))
                pageView.addSubview(text)
                pageView.frame.size.height += text.frame.size.height
            }
        
            label.textAlignment = .left
            label.numberOfLines = 2
            label.font = UIFont(name: "Helvetica", size: 18)
            pageView.addSubview(label)
            label.text = titles[x]
            
            imageView.contentMode = .scaleAspectFit
            //imageView.image = UIImage(named: "welcome_\(x+1)")
            pageView.addSubview(imageView)
            pageView.addSubview(group_img)
            newsfeed?.getData(from: posts[x].group_img, completion: {data, response, error in
                guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? self.posts[x].group_img.lastPathComponent)
                    print("Download Finished")
                    DispatchQueue.main.sync() { [weak self] in
                        group_img.image = UIImage(data: data)
                    }
            })
            
            if posts[x].photos?.count != 0{
            newsfeed?.getData(from: posts[x].photos![0], completion: {data, response, error in
                                       guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? self.posts[x].photos?[0].lastPathComponent)
                                       print("Download Finished", x)
                                       DispatchQueue.main.sync() { [weak self] in
                                        imageView.image = UIImage(data: data)
                                        
                                       }
                
            })
            }
        }
        scrollView.contentSize = CGSize(width: holderView.frame.size.width*CGFloat(posts.count), height: 0)
        scrollView.isPagingEnabled = true
        isLoaded = true
    }

}

extension UILabel{
    func countLabelLines() -> Int {
        // Call self.layoutIfNeeded() if your view is uses auto layout
        let myText = self.text! as NSString
        let attributes = [NSAttributedString.Key.font : self.font]

        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
      func isTruncated() -> Bool {
        if (self.countLabelLines() > self.numberOfLines) {
            return true
        }
        return false
    }
}
