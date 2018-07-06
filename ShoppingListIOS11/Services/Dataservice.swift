//
//  Dataservice.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit
import Firebase

private let DATABASE = Database.database().reference()
private let REF_STORAGE = Storage.storage().reference()

class Dataservice {
    
    static let instance = Dataservice()
    
    // Database references
    
    private var _REF_DATABASE = DATABASE
    private var _REF_USERS = DATABASE.child("users")
    private var _REF_LISTS = DATABASE.child("lists")
    
    // Storage reference
    
    private var _REF_PROFILE_PICS = REF_STORAGE.child("Profile_pic")
    
    // Database
    
    var REF_DATABASE: DatabaseReference {
        return _REF_DATABASE
    }
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    var REF_LISTS: DatabaseReference {
        return _REF_LISTS
    }
    
    // Methods
    
    func createDatabaseUser (uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func createNewShoppingList (uid: String, listName: String) {
        let listID = REF_USERS.child(LISTS).childByAutoId().key
        REF_USERS.child(uid).child(LISTS).child(OWN_LISTS).child(listID).updateChildValues([LIST_ID: listID, LIST_NAME: listName])
        REF_LISTS.child(listID).child(LIST_USERS).updateChildValues([uid: ACTIVE])
    }
    
    func removeShoppingList (uid: String, selectedShoppingList: ListItem) {
        selectedShoppingList.ref?.observeSingleEvent(of: .value, with: { (userListsSnapshot) in
            if userListsSnapshot.exists() {
                selectedShoppingList.ref?.removeValue()
            }
        })
        REF_LISTS.child(selectedShoppingList.listID).observeSingleEvent(of: .value, with: { (selectedListSnapshot) in
            if selectedListSnapshot.exists() {
                self.REF_LISTS.child(selectedShoppingList.listID).child(LIST_USERS).child(uid).removeValue()
                self.REF_LISTS.child(selectedShoppingList.listID).child(LIST_USERS).observeSingleEvent(of: .value, with: { (listUsersSnapshot) in
                    if !listUsersSnapshot.exists() {
                        self.REF_LISTS.child(selectedShoppingList.listID).removeValue()
                    }
                })
            }
        })
    }
    
    func addNewItemToShoppingList(selectedShoppingList: ListItem, newShoppingListItem: ShoppingListItem ) {
        let itemID = REF_LISTS.childByAutoId().key
        let newItem = [ITEM_NAME: newShoppingListItem.itemName, ITEM_QUANTITY: newShoppingListItem.itemQuantity, COMPLETED: newShoppingListItem.completed] as [String: Any]
        REF_LISTS.child(selectedShoppingList.listID).child(LIST_ITEMS).child(itemID).updateChildValues(newItem)
    }
    
    func removeItemFromShoppingList(shoppingListItemToRemove: ShoppingListItem) {
        shoppingListItemToRemove.ref?.removeValue()
    }
} 













