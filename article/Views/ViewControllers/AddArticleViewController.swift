//
//  AddArticleViewController.swift
//  article
//
//  Created by Safhone on 3/6/18.
//  Copyright © 2018 Safhone. All rights reserved.
//

import UIKit
import Photos
import SDWebImage
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa

class AddArticleViewController: UIViewController {

    private var articleViewModel    : ArticleViewModel?
    
    @IBOutlet weak var uploadImageView  : UIImageView!
    @IBOutlet weak var titleTextField   : UITextField!
    @IBOutlet weak var descTextView     : UITextView!
    @IBOutlet weak var barNavigationItem: UINavigationItem!
    
    private let imagePicker = UIImagePickerController()
    
    private var loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var newsID          : Int?
    var newsTitle       : String?
    var newsImage       : String?
    var newsDescription : String?
    
    var isUpdate: Bool = false
    var isSave: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleViewModel = ArticleViewModel()
        
        checkPhotoLibraryPermission()
        imagePicker.delegate = self
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageTapGesture.delegate = self
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(imageTapGesture)
        
        if isUpdate {
            titleTextField.text = newsTitle!
            descTextView.text   = newsDescription!
            if let imgURL = URL(string: newsImage!) {
                uploadImageView.sd_setImage(with: imgURL, placeholderImage: #imageLiteral(resourceName: "sorry-image-not-available"))
            }
        }
        
        _ = titleTextField.rx.text.map { $0 ?? ""}.bind(to: (articleViewModel?.title)!)
        _ = descTextView.rx.text.map { $0 ?? ""}.bind(to: (articleViewModel?.description)!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        IQKeyboardManager.sharedManager().enable                     = true
        IQKeyboardManager.sharedManager().enableAutoToolbar          = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        if isUpdate {
            self.navigationController?.navigationBar.topItem?.title = "Update"
            self.barNavigationItem.title = "Update"
            isSave = false
            return
        } else {
            self.navigationController?.navigationBar.topItem?.title = "Add"
            self.barNavigationItem.title = "Add"
            isSave = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.sharedManager().enable                     = false
        IQKeyboardManager.sharedManager().enableAutoToolbar          = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = false
    }

    @IBAction func saveArticle(_ sender: Any) {
        
        let x = self.view.frame.width / 2
        let y = self.view.frame.height / 2
        
        loadingIndicatorView.center           = CGPoint(x: x, y: y)
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.startAnimating()
        
        let image = UIImageJPEGRepresentation(self.uploadImageView.image!, 1)
        
        if isSave! {
            articleViewModel?.uploadArticleImage(image: image!) {
                self.articleViewModel?.saveArticle(image: (self.articleViewModel?.imageName)!)
                NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil, userInfo: nil)
                self.navigationController?.popViewController(animated: true)
                self.loadingIndicatorView.stopAnimating()
            }
            
        } else {
            articleViewModel?.uploadArticleImage(image: image!) {
                self.articleViewModel?.updateArticle(image: (self.articleViewModel?.imageName)!, id: self.newsID!)
                NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil, userInfo: nil)
                self.navigationController?.popViewController(animated: true)
                self.loadingIndicatorView.stopAnimating()
            }
        }
        
    }
    
}

extension AddArticleViewController: UIGestureRecognizerDelegate {
    @objc func imageTapped(tap: UITapGestureRecognizer) {
        self.imagePicker.allowsEditing  = false
        self.imagePicker.sourceType     = .photoLibrary
        
        present(self.imagePicker, animated: true, completion: nil)
    }
}

extension AddArticleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func checkPhotoLibraryPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.uploadImageView.image = pickedImage
        } else{
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

