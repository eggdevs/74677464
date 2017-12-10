//
//  ErrorHandlingService.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit
import Firebase

class ErrorHandlingService {
    
    static let instance = ErrorHandlingService()
    
    func createFirebaseErrorAlertMessage (error: Error) -> String {
        var errorMsg = ""
        if let errorCode = AuthErrorCode(rawValue: (error._code)) {
            if errorCode == .userNotFound {
                print("1:\(error.localizedDescription)")
                errorMsg = "User not found. Please check your credentials or sign up."
                print(errorMsg)
            } else if errorCode == .emailAlreadyInUse {
                print("2:\(error.localizedDescription)")
                errorMsg = "This e-mail address is already in use."
            } else if errorCode == .invalidEmail {
                print("3:\(error.localizedDescription)")
            } else if errorCode == .wrongPassword {
                print("4:\(error.localizedDescription)")
                errorMsg = "The password is invalid. Please try again."
            }else if errorCode == .weakPassword {
                errorMsg = "Password is too week. Enter a 6 or more digit password please."
                print("5:\(error.localizedDescription)")
            } else {
                print("else:\(error.localizedDescription)")
            }
            return errorMsg
        }
        return "Unknown error occured. Please try again"
    }
}
