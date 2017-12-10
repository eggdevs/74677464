//
//  UIViewExtension.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 03.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit

extension UIView {
    func fadeTo(alphaValue: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
}
