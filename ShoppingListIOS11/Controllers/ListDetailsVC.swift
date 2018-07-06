//
//  ListDetailsVC.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit
import Firebase

class ListDetailsVC: UIViewController {
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shoppingListLbl: UILabel!
    var shoppingList: ListItem!
    var shoppingListItems = [ShoppingListItem] ()
//    var userToShareWithExists = false
    let uid = Auth.auth().currentUser!.uid
    
    @IBAction func addItemPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: "Shopping List Item", message: "Add a new Item", preferredStyle: .alert)
        
        alert.addTextField { (itemTextField) in
            itemTextField.placeholder = "Enter New Item Name"
            itemTextField.delegate = self
        }
        alert.addTextField { (quantityTextField) in
            quantityTextField.placeholder = "Enter Quantity"
            quantityTextField.keyboardType = UIKeyboardType.numberPad
            quantityTextField.delegate = self
        }
        let addAction = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let itemTF = alert.textFields?[0].text, let quantityTF = alert.textFields?[1].text {
                if itemTF != "" && quantityTF != "" {
                    let shoppingListItemToAdd = ShoppingListItem(itemName: itemTF, itemQuantity: quantityTF, completed: false)
                    Dataservice.instance.addNewItemToShoppingList(selectedShoppingList: self.shoppingList, newShoppingListItem: shoppingListItemToAdd)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
//        alert.addTextField()
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareBtnPressed(_ sender: UIBarButtonItem) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        shoppingListLbl.text = shoppingList.listName
        Dataservice.instance.REF_LISTS.child(shoppingList.listID).child(LIST_ITEMS).observe(.value, with: { (listSnapshot) in
            self.shoppingListItems = []
            if listSnapshot.exists() {
                for item in listSnapshot.children {
                    let addedItem = ShoppingListItem(snapshot: item as! DataSnapshot)
                    self.shoppingListItems.append(addedItem)
                }
            }
            self.tableView.reloadData()
        })
        setupToolbar()
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = UIColor(red: 99/255, green: 163/255, blue: 248/255, alpha: 1)
        toolbar.isTranslucent = true
        let shareBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList))
        shareBarBtn.isEnabled = true
        shareBarBtn.tintColor = UIColor.darkText
        toolbar.items = [shareBarBtn]
        view.addSubview(toolbar)
        
    // define constraints
        
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    @objc func shareList() {
        let alert = UIAlertController(title: "Share List", message: "Add email of user you want to share your list with", preferredStyle: .alert)
        
        alert.addTextField { (userTextField) in
            userTextField.placeholder = "Enter user's email here"
            userTextField.keyboardType = UIKeyboardType.emailAddress
            userTextField.delegate = self
        }
       
        let addAction = UIAlertAction(title: "Share", style: .default) { _ in
            if let userTF = alert.textFields?[0].text {
                if userTF != "" {
                    Dataservice.instance.REF_USERS.observeSingleEvent(of: .value, with: { (usersSnapshot) in
                        if usersSnapshot.exists() {
                            for users in usersSnapshot.children {
                                let user = User(snapshot: users as! DataSnapshot)
                                if user.email == userTF {
                                    self.shoppingList.share(thisList: self.shoppingList, with: user, completion: { (error) in
                                        if error != nil {
                                            self.createAlert(titel: "Error", message: error!)
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
                
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
        
    }
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    func createAlert (titel: String, message: String) {
        let alert = UIAlertController(title: titel, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ListDetailsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension ListDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = shoppingListItems[indexPath.row]
        cell.textLabel?.text = item.itemName
        cell.detailTextLabel?.text  = item.itemQuantity
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Dataservice.instance.removeItemFromShoppingList(shoppingListItemToRemove: shoppingListItems[indexPath.row])
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let shoppingListItem = shoppingListItems[indexPath.row]
        toggleCellCheckbox(cell, isCompleted: !shoppingListItem.completed)
        shoppingListItem.ref?.updateChildValues(["completed" : !shoppingListItem.completed])
        tableView.reloadData()
    }
    
   
    
}
