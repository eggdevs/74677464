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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shoppingListLbl: UILabel!
    var shoppingList: ListItem!
    var shoppingListItems = [ShoppingListItem] ()
    let uid = Auth.auth().currentUser!.uid
    
    @IBAction func addItemPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: "Shopping List Item",
                                      message: "Add a new Item",
                                      preferredStyle: .alert)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoppingListLbl.text = shoppingList.listName
        Dataservice.instance.REF_LISTS.child(shoppingList.listID).child("list items").observe(.value, with: { (listSnapshot) in
            self.shoppingListItems = []
            if listSnapshot.exists() {
                for item in listSnapshot.children {
                    let addedItem = ShoppingListItem(snapshot: item as! DataSnapshot)
                    self.shoppingListItems.append(addedItem)
                }
            }
            self.tableView.reloadData()
        })
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
