//
//  UIDeviceExtension.swift
//  VoiceToChat
//
//  Created by Shree on 02/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

extension UIApplication {

    static var isDeviceWithSafeArea:Bool {

        if #available(iOS 11.0, *) {
            if let topPadding = shared.keyWindow?.safeAreaInsets.bottom,
                topPadding > 0 {
                return true
            }
        }

        return false
    }
}
