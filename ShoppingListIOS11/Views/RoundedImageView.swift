//
//  RoundedImageView.swift
//  ShoppingListIOS11
//
//  Created by Xavier Eggen on 04.12.17.
//  Copyright © 2017 EggDevs. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
    
}

