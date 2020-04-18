//
//  ModelUserList.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

//MARK: - Model User List
class ModelUserList: NSObject {
    var isSelected = false
    var isClose = false
    var strUserName = ""
    var userId = 0
    
    init(strUserName:String,userId:Int) {
        self.strUserName = strUserName
        self.userId = userId
    }
}

//MARK: - Cell User List
class CellUserList : UITableViewCell {
    
    @IBOutlet var controlCheckbox: UIControl!
    @IBOutlet var imgRightSign: UIImageView!
    @IBOutlet var controlCloseBG: UIControl!
    @IBOutlet var viewCloseBG: UIView!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var constraintWidthClose: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Prepare UI
        self.prepareUI()
    }
    func setData(data: ModelUserList) {

        self.lblUsername.text = data.strUserName

        if data.isClose {
             self.constraintWidthClose.constant = 50
        } else {
             self.constraintWidthClose.constant = 0
        }
        self.imgRightSign.isHidden = !data.isSelected
    }
    func prepareUI() {

        //self.viewCloseBG.layer.cornerRadius = 10
        self.controlCheckbox.layer.borderWidth = 1
        self.controlCheckbox.layer.borderColor = UIColor.init(red: 246/255, green: 97/255, blue: 62/255, alpha: 1.0).cgColor
        self.imgRightSign.setImageColor(color: UIColor.init(red: 246/255, green: 97/255, blue: 62/255, alpha: 1.0))
    }

    func showCloseButton() {
        self.constraintWidthClose.constant = 50
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    func hideCloseButton() {
        self.constraintWidthClose.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}
