import Foundation
import SwiftyVK


final class APIWorker {

    class func authorize()-> Bool {
        var chk = true
        VK.sessions.default.logIn(
            onSuccess: { info in
                print("SwiftyVK: success authorize with", info)
                
            },
            onError: { error in
                print("SwiftyVK: authorize failed with", error)
                chk = false            }
        )
        return chk
    }
    
    class func logout() {
        VK.sessions.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
    class func captcha() {
        VK.API.Custom.method(name: "captcha.force")
            .onSuccess { print("SwiftyVK: captcha.force successed with \n \(JSON($0))") }
            .onError { print("SwiftyVK: captcha.force failed with \n \($0)") }
            .send()
    }
    
    class func validation() {
        VK.API.Custom.method(name: "account.testValidation")
            .onSuccess { print("SwiftyVK: account.testValidation successed with \n \(JSON($0))") }
            .onError { print("SwiftyVK: account.testValidation failed with \n \($0)") }
            .send()
    }
    
    class func usersGet() {
        VK.API.Users.get(.empty)
            .configure(with: Config.init(httpMethod: .POST))
            .onSuccess { print("SwiftyVK: users.get successed with \n \(JSON($0))") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    class func friendsGet() {
        VK.API.Friends.get(.empty)
            .onSuccess { print("SwiftyVK: friends.get successed with \n \(JSON($0))") }
            .onError { print("SwiftyVK: friends.get failed with \n \($0)") }
            .send()
    }
    
}
