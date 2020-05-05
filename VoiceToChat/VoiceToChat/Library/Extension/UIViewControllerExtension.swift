//
//  UIViewControllerExtension.swift
//  VoiceToChat
//
//  Created by Shree on 06/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit
import SwiftMessages

extension UIViewController {
    func showAlert (title:String, message:String,buttonName:String, completion:@escaping (_ result:Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)

        alert.addAction(UIAlertAction(title: buttonName, style: .default, handler: { action in
            completion(true)
        }))
    }
    
    func showMessageView(title: String = appName, message: String, theme:Theme = .warning) {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(theme)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.iconImageView?.isHidden = true
        view.titleLabel?.isHidden = true
        view.bodyLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        
        //view.configureContent(title:title, body: message, iconImage: UIImage(named:"popupIcon")!)
        view.configureContent(title:title, body: message)
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(view: view)
    }
}
