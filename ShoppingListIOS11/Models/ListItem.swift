//
//  ListItem.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 04.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import Foundation
import Firebase

struct ListItem {
    
    let listID: String
    let listName: String
    let ref: DatabaseReference?
    
    init(listName: String, listID: String = "") {
        self.listID = listID
        self.listName = listName
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        listName = snapshotValue["list name"] as! String
        listID = snapshotValue["listID"] as! String
        ref = snapshot.ref
    }

    func toAnyObject() -> Any {
        return ["list name": listName, "listID": listID]
    }
    
}
