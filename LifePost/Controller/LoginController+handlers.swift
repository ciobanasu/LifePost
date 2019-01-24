//
//  LoginController+handlers.swift
//  LifePost
//
//  Created by Ciobanasu Ion on 1/12/19.
//  Copyright © 2019 Ciobanasu Ion. All rights reserved.
//

import UIKit
import Firebase
import Photos

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // register
    func handleRegister() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = nameTextField.text else {
                print("Form is not valid")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            // successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child(PROFILE_IMAGES).child("\(imageName).jpg")
            // compress photo
            if let uploadData = self.profileImageView.image?.jpegData(compressionQuality: 0.01) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil, metadata != nil {
                        print(error ?? "")
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error ?? "")
                            return
                        }
                        if let profileImageUrl = url?.absoluteString {
                            let values = [NAME: name,  EMAIL: email, PROFILE_IMAGE_URL: profileImageUrl]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                    })
                })
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String : AnyObject]) {
        self.loginRegisterButton.startAnimation()
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        let ref = Database.database().reference(fromURL: URL_DB)
        let usersReference = ref.child(USERS_REF).child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return 
            }
            // successfully added a user into DB
            print("User was added into Firebase DB")
            backgroundQueue.async(execute: {
                sleep(3)
                DispatchQueue.main.async(execute: {
                    self.loginRegisterButton.stopAnimation(animationStyle: .expand, completion: {
                        //self.messageController?.fetchUserSetupNavBarTitle()
                        //self.messageController?.navigationItem.title = values[NAME] as? String
                        let user = User()
                        user.setValuesForKeys(values)
                        self.messageController?.setupNavBarWithUser(user: user)
                        
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        })
    }
    
    func mediaAccesWasDenied(title: String) {
        let alert = UIAlertController(title: title, message: "Access was denied", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleProfileImageView(_ gestureRecognizer: UITapGestureRecognizer) {

        let alert = UIAlertController(title: "Import a photo from", message: "", preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (photoLibrary) in
           // let photos = PHPhotoLibrary.authorizationStatus()
           // if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized {
                        let picker = UIImagePickerController()
                        picker.delegate = self
                        picker.sourceType = .photoLibrary
                        picker.allowsEditing = true
                        self.present(picker, animated: true, completion: nil)
                    }
                    else {
                        self.mediaAccesWasDenied(title: "Photo library acces was denied")
                    }
                })
            //}
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (camera) in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { response in
                if response {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .camera
                    picker.allowsEditing = true
                    self.present(picker, animated: true, completion: nil)
                } else {
                    self.mediaAccesWasDenied(title: "Camera acces was denied")
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.layer.masksToBounds = true
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
