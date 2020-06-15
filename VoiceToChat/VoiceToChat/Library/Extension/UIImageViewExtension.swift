//
//  UIImageViewExtension.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
