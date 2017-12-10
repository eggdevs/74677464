//
//  ListsVC.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit
import Firebase

class ListsVC: UIViewController, Alertable {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var shoppingLists = [ListItem]()
    let uid = Auth.auth().currentUser!.uid
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            let errorMsg = error.localizedDescription
            self.showAlert(errorMsg)
        }
    }
    
    @IBAction func createNewListPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Shopping List",
                                      message: "Add a new List",
                                      preferredStyle: .alert)
        
        alert.addTextField { (listTextField) in
            listTextField.placeholder = "Enter New List Name"
            listTextField.delegate = self
        }
        let addAction = UIAlertAction(title: "Add List", style: .default) { _ in
            if let listNameTF = alert.textFields?[0].text {
                if listNameTF != "" {
                    Dataservice.instance.createNewShoppingList(uid: self.uid, listName: listNameTF.capitalized)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",style: .default)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Dataservice.instance.REF_USERS.child(uid).child("shopping lists").observe(.value, with: { (snapshot) in
            self.shoppingLists = []
            if snapshot.exists() {
                for item in snapshot.children {
                    let listItem = ListItem(snapshot: item as! DataSnapshot)
                    self.shoppingLists.append(listItem)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listDetailsVC = segue.destination as! ListDetailsVC
        listDetailsVC.shoppingList = sender as! ListItem
    }
}

extension ListsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension ListsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let shoppingList = shoppingLists[indexPath.row]
        cell.textLabel?.text = shoppingList.listName
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Dataservice.instance.removeShoppingList(uid: uid, selectedShoppingList: shoppingLists[indexPath.row])
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToListDetails", sender: shoppingLists[indexPath.row])
    }
    
}
