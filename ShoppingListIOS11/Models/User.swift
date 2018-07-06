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
    
    let uid: String?
    let email: String
    let ref: DatabaseReference?
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email
        ref = nil
    }
    
    init(email: String) {
        self.uid = nil
        self.email = email
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshot.key as String
        email = snapshotValue["email"] as! String
        ref = snapshot.ref
    }
}

