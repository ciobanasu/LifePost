//
//  ViewController.swift
//  LifePost
//
//  Created by Ciobanasu Ion on 1/11/19.
//  Copyright © 2019 Ciobanasu Ion. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
//        checkIfUserIsLoggedIn()
//        
//        view.addSubview(imageView)
//        
//        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child(USERS_REF).child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.navigationItem.title = dictionary[NAME] as? String
                }
                
            }, withCancel: nil)
        }
    }
    
    @objc func handleLogout() {
        // sign out
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
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
