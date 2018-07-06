//
//  LoginVC.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, Alertable {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginSelector: UISegmentedControl!
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        var errorMsg = ""
        // MARK: loginSelector set to Sign In:
        if loginSelector.selectedSegmentIndex == 0 {
            if let email = emailTextField.text , let password = passwordTextField.text {
                if email == "" || password == "" {
                    errorMsg = "Enter Email and Password"
                    self.showAlert(errorMsg)
                } else {
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            errorMsg = ErrorHandlingService.instance.createFirebaseErrorAlertMessage(error: error!)
                            self.showAlert(errorMsg)
                        } else {
                           self.performSegue(withIdentifier: "goToLists", sender: nil)
                        }
                    })
                }
            }
        // MARK: loginSelector set to Sign Up:
        } else {
            if let email = emailTextField.text , let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text {
                if email == "" || password == "" || confirmPassword == "" {
                    errorMsg = "Enter Email and Passwords"
                    self.showAlert(errorMsg)
                } else if password != confirmPassword {
                    errorMsg = "Your passwords do not match"
                    self.showAlert(errorMsg)
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            errorMsg = ErrorHandlingService.instance.createFirebaseErrorAlertMessage(error: error!)
                            self.showAlert(errorMsg)
                        } else {
                            let currentUser = Auth.auth().currentUser!
                            let userData: Dictionary<String, Any> = ["provider": currentUser.providerID, "email": currentUser.email!]
                            Dataservice.instance.createDatabaseUser(uid: currentUser.uid, userData: userData)
                            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                                if let error = error {
                                    errorMsg = ErrorHandlingService.instance.createFirebaseErrorAlertMessage(error: error)
                                    self.showAlert(errorMsg)
                                } else {
                                    self.performSegue(withIdentifier: "goToLists", sender: nil)
                                }
                            })
                        }
                    })
                }
            }
        }
        
    }
    
    @IBAction func loginSelectorToggled(_ sender: UISegmentedControl) {
        if loginSelector.selectedSegmentIndex == 0 {
            loginBtn.setTitle("Sign In", for: .normal)
            confirmPasswordTextField.fadeTo(alphaValue: 0.0, withDuration: 0.3)
            confirmPasswordTextField.isHidden = true
            updateKeyboardReturnKey(textField: passwordTextField, returnKey: .done)
        } else {
            confirmPasswordTextField.isHidden = false
            loginBtn.setTitle("Sign Up", for: .normal)
            confirmPasswordTextField.fadeTo(alphaValue: 1.0, withDuration: 0.3)
            updateKeyboardReturnKey(textField: passwordTextField, returnKey: .next)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func updateKeyboardReturnKey (textField: UITextField, returnKey: UIReturnKeyType) {
        textField.returnKeyType = returnKey
        reloadInputViews()
        if textField.isFirstResponder {
            textField.becomeFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notif: NSNotification) {
        if ((notif.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y = -150
            }
        }
    }
    
    
    @objc func keyboardWillHide(notif: NSNotification) {
        if ((notif.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder && loginSelector.selectedSegmentIndex == 1 {
            passwordTextField.returnKeyType = .next
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            passwordTextField.returnKeyType = .done
            resignFirstResponder()
            view.endEditing(true)
        }
        return true
    }
}
