//
//  Album.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

class Album: NSObject {
    var owner:User!
    private var photos:[UIImage] = []
    private var photosURL:[URL] = []
    private var url:URL?
    var name:String!
    init(name:String, owner:User) {
        self.owner = owner
        self.name = name
    }
    
    func getURL() -> URL? {
        return self.url
    }
    
    func addPhoto(imgURL:URL) {
        self.photosURL.append(imgURL)
        if let img = UIImage(named: imgURL.absoluteString) {
            self.addPhoto(img: img)
        }
    }
    
    func addPhoto(img:UIImage) {
        self.photos.append(img)
    }
    
    func addToFirestore() {
        let db = Firestore.firestore()
        let ownerDetails = ["firstName":self.owner.firstName,
                            "lastName": self.owner.lastName,
                            "email":self.owner.email,
                            "uid": self.owner.id]
        let d:[String : Any] = ["Name":self.name, "ownerID":self.owner.id, "owner": ownerDetails]
        db.collection("Albums").addDocument(data: d, completion: { (err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        })
    }
}
