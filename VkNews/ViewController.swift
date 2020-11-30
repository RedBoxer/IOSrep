//
//  ViewController.swift
//  VkNews
//
//  Created by user184905 on 11/30/20.
//  Copyright © 2020 user184905. All rights reserved.
//

import UIKit
import SwiftyVK

class ViewController: UIViewController {

    @IBOutlet weak var Text: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    

    @IBAction func buttonPressed(_ sender: UIButton) {
        let AuthResult = APIWorker.authorize()
        if (AuthResult)
        {
            var response: JSON
            response = nil
            VK.API.Users.get(.empty).onSuccess{
                response = try JSON(data: $0)
            }.send()
            if(response != nil){
                Text.text = response["user_id"].stringValue
            }
        }
    }
    
    @IBAction func labelUpdatePressed(_ sender: UIButton) {
        setLabel()
    }
    func setLabel(){
        var response: JSON
        response = nil
        VK.API.Users.get(.empty).onSuccess{
            print("trying")
            response = try JSON(data: $0)
        }
        .onError{_ in print("fail")}.send()
        if(response != nil){
            Text.text = response["user_id"].stringValue
        }
        
    }
}

