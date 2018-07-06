//
//  ShoppingListItem.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 04.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import Foundation
import Firebase

struct ShoppingListItem {
    
    let itemName: String
    let itemQuantity: String
    let ref: DatabaseReference?
    var completed: Bool
    var listUsers: [String]?
    
    init(itemName: String, itemQuantity: String, completed: Bool = false) {
        self.itemName = itemName
        self.itemQuantity = itemQuantity
        self.completed = completed
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        itemName = snapshotValue["item name"] as! String
        itemQuantity = snapshotValue["item quantity"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "item name": itemName,
            "item quantity": itemQuantity,
            "completed": completed
        ]
    }
    
}
