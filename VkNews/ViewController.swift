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
        
    struct User: Codable {
        var first_name: String
        var last_name: String
        var id: CUnsignedLong
        var can_access_closed: Bool
        var is_closed: Bool
    }
    @IBOutlet weak var LogOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (VK.sessions.default.state == .authorized){
            setLabel()
            LogOutButton.isEnabled = true
        }
    }

    @IBAction func GoToNewsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToNews", sender: self)
    }
    
    @IBOutlet weak var Label: UILabel!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if(APIWorker.authorize()){
            LogOutButton.isEnabled = true
        }
        
    }
    
    @IBAction func LogOutButtonPressed(_ sender: UIButton) {
        APIWorker.logout()
        Label.text = "No one logged in"
        LogOutButton.isEnabled =  false
    }
    
    var users: [User] = []
    func setLabel(){
        var responseRecieved = false
        var fail = false
        let decoder = JSONDecoder()
        VK.API.Users.get([.userId: "", .fields:"first_name,last_name"]).onSuccess{response in
            self.users = try decoder.decode([User].self, from: response)
            responseRecieved = true
        }
        .onError{_ in print("fail")
            fail = true}.send()
        while(!fail && !responseRecieved){
            
        }
        if (!fail){
            Label.text = users[0].first_name + " " + users[0].last_name + " currently logged in"
        }
    }
    
    
}

