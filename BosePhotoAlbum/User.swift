//
//  User.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class User: NSObject {
    var firstName:String?
    var lastName:String?
    var email:String?
    var id:String!
    
    init(firstName:String?, lastName:String?, email:String?, id:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
    }
}
