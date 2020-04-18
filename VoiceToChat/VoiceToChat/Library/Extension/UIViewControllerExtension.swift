//
//  UIViewControllerExtension.swift
//  VoiceToChat
//
//  Created by Shree on 06/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert (title:String, message:String,buttonName:String, completion:@escaping (_ result:Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)

        alert.addAction(UIAlertAction(title: buttonName, style: .default, handler: { action in
            completion(true)
        }))
    }
}
