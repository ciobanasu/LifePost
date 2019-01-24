//
//  ViewController.swift
//  LifePost
//
//  Created by Ciobanasu Ion on 1/11/19.
//  Copyright © 2019 Ciobanasu Ion. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController , animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserSetupNavBarTitle()
        }
    }
    
    func fetchUserSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
   Database.database().reference().child(USERS_REF).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                //self.navigationItem.title = dictionary[NAME] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }

    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImage = user.profileImageUrl {
            profileImageView.cacheImage(urlString: profileImage)
        }
        titleView.addSubview(profileImageView)
         //constraints
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)
        nameLabel.text = user.name

        // constraints
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.heightAnchor ).isActive = true

        self.navigationItem.titleView = titleView
        let showChatControllerTap = UITapGestureRecognizer(target: self, action: #selector(showChatController(_:)))
        titleView.addGestureRecognizer(showChatControllerTap)
    }
    
    @objc func showChatController(_ gestureRecognizer: UITapGestureRecognizer) {
        print(1234)
    }
    
    @objc func handleLogout() {
        // sign out
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    // download profile image
    @objc func downloadProfileImage() {
        let ref = Database.database().reference(fromURL: URL_DB)
        let uid = Auth.auth().currentUser?.uid
        let usersReference = ref.child(USERS_REF).child(uid!)
        
        usersReference.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() { return }
            // print snapshot
            
            let userInfo = snapshot.value as! NSDictionary
            if let userName = userInfo[NAME] {
                print(userName)
            }
            if let profileUrl = userInfo[PROFILE_IMAGE_URL] as? String {
                print(profileUrl)
            }
        }
    }
}
