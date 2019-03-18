//
//  ImageViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image:UIImage!
    
    let imageView:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.image = image
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}
