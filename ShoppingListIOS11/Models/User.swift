//
//  User.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 04.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}

