//
//  ImageViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: UIViewController {
    
    var image:UIImage!
    var imageID:String?
    var token:String?
    
    var userID:String?
    
    let uid = Auth.auth().currentUser?.uid
    
    let progressView = UIActivityIndicatorView(style: .gray)
    
    let window = UIApplication.shared.keyWindow
    
    let imageView:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addSubview(progressView)
        progressView.center = view.center
        progressView.hidesWhenStopped = true
        if let imageID = imageID {
            if let token = token {
                let url = "https://firebasestorage.googleapis.com/v0/b/bose-photo-album.appspot.com/o/\(String(describing: imageID)).jpg?alt=media&token=\(String(describing: token))"
                loadImageFromURL(url:url)
            }
        } else {
            imageView.image = image
        }
//        if let userID = userID {
//            if userID == uid {
//                print("owner")
//            } else {
//                print("read only")
//            }
//        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    var hide = true
    @objc func handleTap() {
        imageView.backgroundColor = hide ? .black : .white
        navigationController?.setNavigationBarHidden(hide, animated: true)
        NotificationCenter.default.post(name: .showHidePlayer, object: nil)
        hide.toggle()
    }
    
    func loadImageFromURL(url:String) {
        progressView.startAnimating()
        DispatchQueue.global(qos: .background).async {
            if let _url = URL(string:url) {
                print(_url.absoluteString)
                URLSession.shared.dataTask(with: _url, completionHandler: { (data, response, dataTaskError) in
                    if let dataTaskError = dataTaskError {
                        print(dataTaskError.localizedDescription)
                        DispatchQueue.main.async {
                            self.progressView.stopAnimating()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.progressView.stopAnimating()
                        if let data = data {
                            if let image = UIImage(data: data) {
                                self.imageView.image = image
                            }
                        }
                    }
                }).resume()
            } else {
                DispatchQueue.main.async {
                    self.progressView.stopAnimating()
                }
            }
        }
    }
}
