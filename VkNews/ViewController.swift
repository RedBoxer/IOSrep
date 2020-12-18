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
    @IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var LogInButton: UIButton!
    @IBOutlet weak var GoToNewsButton: UIButton!
    @IBOutlet weak var Label: UILabel!
    
    struct User: Codable {
        var first_name: String
        var last_name: String
        var id: CUnsignedLong
        var can_access_closed: Bool
        var is_closed: Bool
    }
    
   
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateViewContent()
    }
    
    func updateViewContent(){
        if (VK.sessions.default.state == .authorized){
            setLabel()
            LogOutButton.isEnabled = true
            GoToNewsButton.isEnabled = true
            LogInButton.isEnabled = false
        }else{
            Label.text = "No one logged in"
            LogOutButton.isEnabled =  false
            GoToNewsButton.isEnabled = false
            LogInButton.isEnabled = true
        }
    }

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "GoToNews") {

            let yourNextViewController = (segue.destination as? NewsViewController)
                
            
        }
       
    }*/
    @IBAction func GoToNewsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToNews", sender: self)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
      VK.sessions.default.logIn(
            onSuccess: { info in
                DispatchQueue.main.async {
                    self.updateViewContent()
                }
            },
            onError: { error in
                print("SwiftyVK: authorize failed with", error)
            }
        )
    }
    
    @IBAction func LogOutButtonPressed(_ sender: UIButton) {
        APIWorker.logout()
        updateViewContent()
    }
    
    func setLabel(){
        let decoder = JSONDecoder()
        VK.API.Users.get([.userId: "", .fields:"first_name,last_name"])
        .onSuccess{response in
            self.users = try decoder.decode([User].self, from: response)
            DispatchQueue.main.async {
                self.Label.text = self.users[0].first_name + " " + self.users[0].last_name + " currently logged in"
            }
        }
        .onError{_ in print("fail")}.send()
    }
}

