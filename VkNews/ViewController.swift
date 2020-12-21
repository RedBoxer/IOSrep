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
    @IBOutlet weak var profile_pic: UIImageView!
    
    struct User: Codable {
        var first_name: String
        var last_name: String
        var id: CUnsignedLong
        var can_access_closed: Bool
        var is_closed: Bool
        var photo_100: URL
    }
    
   
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateViewContent()
        LogInButton.setTitleColor(.white, for: .normal)
        LogInButton.setTitleColor(.gray , for: .disabled)
        
        LogOutButton.setTitleColor(.white, for: .normal)
        LogOutButton.setTitleColor(.gray , for: .disabled)
        
        GoToNewsButton.setTitleColor(.white, for: .normal)
        GoToNewsButton.setTitleColor(.gray , for: .disabled)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            //show onboarding
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    func updateViewContent(){
        let state = VK.sessions.default.state == .authorized
        if (state){
            setLabel()
            LogOutButton.isEnabled = true
            LogOutButton.backgroundColor = .black
            GoToNewsButton.isEnabled = true
            GoToNewsButton.backgroundColor = .black
            LogInButton.isEnabled = false
            LogInButton.backgroundColor = .white
        }else{
            Label.text = "No one logged in"
            LogOutButton.isEnabled =  false
            LogOutButton.backgroundColor = .white
            GoToNewsButton.isEnabled = false
            GoToNewsButton.backgroundColor = .white
            LogInButton.isEnabled = true
            LogInButton.backgroundColor = .black
            profile_pic.image = UIImage(named: "welcome_1")
        }
    }

    @IBAction func GoToNewsPressed(_ sender: UIButton) {
        //performSegue(withIdentifier: "GoToNews", sender: self)
        let vc = storyboard?.instantiateViewController(identifier: "NewsScroll") as! NewNewsViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func setLabel(){
        let decoder = JSONDecoder()
        VK.API.Users.get([.userId: "", .fields:"first_name,last_name,photo_100"])
        .onSuccess{response in
            self.users = try decoder.decode([User].self, from: response)
            DispatchQueue.main.async {
                self.Label.text = self.users[0].first_name + " " + self.users[0].last_name + " currently logged in"
                self.getData(from: self.users[0].photo_100, completion:{data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? self.users[0].photo_100.lastPathComponent)
                    print("Download Finished")
                    DispatchQueue.main.sync() { [weak self] in
                        self!.profile_pic.image = UIImage(data: data)
                    }
            })
        }
        }
        .onError{_ in print("Set Label fail")}.send()
    }
}

class Core {
       static let shared = Core()
       
       func isNewUser()->Bool{
           return !UserDefaults.standard.bool(forKey: "isNewUser")
       }
       
       func setIsNotNewUser(){
           UserDefaults.standard.set(true, forKey: "isNewUser")
       }
   }
