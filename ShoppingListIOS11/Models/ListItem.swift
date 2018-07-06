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
        listName = snapshotValue[LIST_NAME] as! String
        listID = snapshotValue[LIST_ID] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [LIST_NAME: listName, LIST_ID: listID]
    }
    
    func populateListArray(_ lists: DataSnapshot) -> [String] {
        var populatedArray: [String] = []
        
        let listCollection = lists.value as! [String : AnyObject]
        for list in listCollection {
           populatedArray.append(list.key)
        }
        return populatedArray
    }
    
    func share(thisList: ListItem, with user: User, completion: @escaping (_ error: String?)->()) {
        var errorMessage: String?
        var pendingShareLists: [String] = []
        var blockedLists: [String] = []
        var sharedLists: [String] = []
        var ownLists: [String] = []
        user.ref?.child(LISTS).observeSingleEvent(of: .value, with: { (listsSnapshot) in
            
            for lists in listsSnapshot.children.allObjects as! [DataSnapshot] {
                switch lists.key {
                case OWN_LISTS:
                    ownLists = self.populateListArray(lists)
                case SHARED_LISTS:
                    sharedLists = self.populateListArray(lists)
                case BLOCKED_LISTS:
                    blockedLists = self.populateListArray(lists)
                case PENDING_LISTS:
                    pendingShareLists = self.populateListArray(lists)
                default:
                    break
                }
            }
            
            for list in ownLists {
                if thisList.listID == list {
                    errorMessage = "Cannot share lists with yourself!"
                }
            }
            for list in blockedLists {
                if thisList.listID == list {
                    errorMessage = "User blocked your share request"
                }
            }
            for list in sharedLists {
                if thisList.listID == list {
                    errorMessage = "User already using your list"
                }
            }
            for list in pendingShareLists {
                if thisList.listID == list {
                    errorMessage = "Waiting for user to accept your list"
                }
            }
            if errorMessage == nil {
                user.ref?.child(LISTS).child(PENDING_LISTS).updateChildValues([self.listID: [LIST_NAME : thisList.listName, LIST_ID : thisList.listID ]])
            }
            completion(errorMessage)
        })
    }
}
