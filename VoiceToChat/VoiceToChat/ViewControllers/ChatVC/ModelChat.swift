//
//  ModelChat.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

//MARK: - Model Chat
class ModelChatWithDate: NSObject {
    var strDate = ""
    var arrChat = [ModelChat]()
    
    init(strDate: String,arrChat:[ModelChat]) {
        self.strDate = strDate
        self.arrChat = arrChat
    }
}
//MARK: - Model Chat
class ModelChat: NSObject {
    
    var strMessage = ""
    var messageId = 0
    var strDate = ""
    var strTime = ""
    
    init(messageId: Int,strMessage:String,strDate:String,strTime:String) {
        self.strMessage = strMessage
        self.messageId = messageId
        self.strDate = strDate
        self.strTime = strTime
    }
}

//MARK: - Cell Chat
class CellChat : UITableViewCell {
    
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var viewCellBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Prepare UI
        self.prepareUI()
    }
    func setData(data: ModelChat) {

        self.lblMessage.text = data.strMessage
        self.lblTime.text = data.strTime
    }
    func prepareUI() {

        self.viewCellBG.layer.cornerRadius = 15
    }
}
