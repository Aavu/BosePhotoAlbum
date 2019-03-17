//
//  AlbumsCell.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class AlbumsCell: UICollectionViewCell {
    let iconView: UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "folder"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let albumLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Album Name"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(iconView)
        self.addSubview(albumLabel)
        iconView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        iconView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        albumLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor).isActive = true
        albumLabel.leftAnchor.constraint(equalTo: iconView.leftAnchor).isActive = true
        albumLabel.rightAnchor.constraint(equalTo: iconView.rightAnchor).isActive = true
        albumLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
