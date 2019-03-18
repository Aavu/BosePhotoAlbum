//
//  PhotosCell.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "folder"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    let deleteBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "checkMark"), for: UIControl.State.normal)
        btn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        btn.widthAnchor.constraint(equalTo: btn.heightAnchor).isActive = true
        btn.isHidden = true
        return btn
    }()
    
    var isEditing: Bool = false {
        didSet {
            deleteBtn.isHidden = !isEditing
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(deleteBtn)
        deleteBtn.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        deleteBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
