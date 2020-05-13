//
//  UserListVC.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

//MARK: - User List View Controller
class UserListVC: UIViewController {

    //TODO: - Outlet Declaration
    @IBOutlet var tblUserlist: UITableView!
    @IBOutlet var imgSettings: UIImageView!
    @IBOutlet var imgMinus: UIImageView!
    @IBOutlet var imgPlus: UIImageView!
    
    @IBOutlet var constraintHeightBannerAds: NSLayoutConstraint!
    
    //TODO: - Variable Declaration
    var arrUserList = [ModelUserList]()
    var db:DBHelper = DBHelper()
    
    var heightBannerView = 0
    
    //TODO: - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prepare UI
        self.prepareUI()
        
        //Prepare Data
        self.prepareData()
    }
    func prepareUI() {
        
        //Change Image Color
        self.imgSettings.setImageColor(color: .black)
        self.imgPlus.setImageColor(color: .black)
        self.imgMinus.setImageColor(color: .black)
        
    }
    func prepareData() {
        
        //Reload User Data
        self.reloadUserData(isScrollToBottom: true)
        
        //Check Device Orientation
        self.checkDeviceOrientation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bannerAdsReceived(notification:)), name: Notification.Name("bannerAdsReceived"), object: nil)
        
//        print("========================")
//        print("\("Test1".localizeString(language: "en"))")
//        print("\("Test1".localizeString(language: "ja"))")
//        print("========================")
    }
    
    func reloadUserData(isScrollToBottom:Bool) {
        self.arrUserList.removeAll()
        self.arrUserList = self.db.readUserInfo()
        self.tblUserlist.reloadData()
        
        if self.arrUserList.count > 1 && isScrollToBottom == true {
            //Scroll To Bottom
            self.scrollToBottom(isAnimated: true)
        }
    }
    func alertWithTextField(title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String) -> Void) = { _ in }) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
            newTextField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel".localizeString(), style: .cancel) { _ in completion("") })
        alert.addAction(UIAlertAction(title: "Save".localizeString(), style: .default) { action in
            if
                let textFields = alert.textFields,
                let tf = textFields.first,
                let result = tf.text
            { completion(result) }
            else
            { completion("") }
        })
        //self.navigationController.present(alert, animated: true)
        self.navigationController?.present(alert, animated: true, completion: {})
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        //Check Device Orientation
        self.checkDeviceOrientation()
        
        NotificationCenter.default.post(name: Notification.Name("changeAppOrientation"), object: nil)
    }
    func checkDeviceOrientation() {
        
        var isPortrait = true
        switch UIDevice.current.orientation {
        case .portrait:
            
            break
        case .portraitUpsideDown:
            
            break
        case .landscapeLeft:
            isPortrait = false
            break
        case .landscapeRight:
            isPortrait = false
            break
        default:
            
            break
        }
        //Update Banner Ads Size
        self.updateBannerAdsSize(isPortrait: isPortrait)
    }
    func updateBannerAdsSize(isPortrait:Bool) {
        
        if UserDefaults.Main.bool(forKey: .isBannerAdsReceived) {
            
            if UserDefaults.Main.bool(forKey: .isRemovedAds) == false {
                
                if UserDefaults.Main.bool(forKey: .isShowBannerAds) {
                    
                    if isPortrait == true {
                        heightBannerView = 50
                        constraintHeightBannerAds.constant = 50
                    } else {
                        if isIphoneXOrLonger == true {
                            heightBannerView = 50
                            constraintHeightBannerAds.constant = 50
                        } else {
                            heightBannerView = 50
                            constraintHeightBannerAds.constant = 50
                        }
                    }
                } else {
                    heightBannerView = 0
                    constraintHeightBannerAds.constant = 0
                }
            } else {
                heightBannerView = 0
                constraintHeightBannerAds.constant = 0
            }
        } else {
            heightBannerView = 0
            constraintHeightBannerAds.constant = 0
        }
    }
    @objc func bannerAdsReceived(notification: Notification) {
        
        self.checkDeviceOrientation()
    }
}
//MARK: - Tapped Event
extension UserListVC {
    @IBAction func tappedOnSettings(_ sender: Any) {
        
        //Redirect To Settings Screen
        self.redirectToSettingsScreen()
    }
    @IBAction func tappedOnMinus(_ sender: Any) {
        
        var isDataSelected = false
        for data in self.arrUserList {
            
            if data.isSelected == true {
                isDataSelected = true
                break;
            }
        }
        
        if isDataSelected == true {
            
            let dialogMessage = UIAlertController(title:nil, message: "Are you sure you want to delete selected user?", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                    
                var i = 0
                for data in self.arrUserList {
                    if(data.isSelected) {
                        
                        //Delete User By ID
                        self.db.deleteUserByID(userId: self.arrUserList[i].userId)
                        
                    } else {
                        
                    }
                    i = i + 1;
                }
                
                //Reload User Data
                self.reloadUserData(isScrollToBottom: false)
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
    @IBAction func tappedOnPlus(_ sender: Any) {
        
        alertWithTextField(title: "Username".localizeString(), message: "", placeholder: "Enter username".localizeString()) { result in
            
            if(result.length > 0) {
                let data = ModelUserList.init(strUserName: result, userId: 0)

                //Insert User Info
                self.db.insertUserInfo(data: data)
                
                //Reload User Data
                self.reloadUserData(isScrollToBottom: true)
            }
        }
    }
    @IBAction func tappedOnUserCheckEvent(_ sender: Any) {
        
        let control = sender as! UIControl
        let index = control.tag
        self.arrUserList[index].isSelected = !self.arrUserList[index].isSelected
        self.tblUserlist.reloadData()
    }
    @IBAction func tappedOnClose(_ sender: Any) {
        
        let control = sender as! UIControl
        let index = control.tag
        
        let dialogMessage = UIAlertController(title:nil, message: "Are you sure you want to delete this?", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            //Delete User By ID
            self.db.deleteUserByID(userId: self.arrUserList[index].userId)
            
            //Reload User Data
            self.reloadUserData(isScrollToBottom: false)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate
extension UserListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrUserList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"CellUserList" , for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cellUser = cell as? CellUserList {
    
            let data = self.arrUserList[indexPath.row]
            cellUser.setData(data: data)
            cellUser.tag = indexPath.row
            cellUser.controlCloseBG.tag = indexPath.row
            cellUser.controlCheckbox.tag = indexPath.row
            
            //Swipe gesture
            let leftSwipeGesture = UISwipeGestureRecognizer(target : self, action : #selector(UserListVC.swipeGesture))
            leftSwipeGesture.direction = .left
            cellUser.addGestureRecognizer(leftSwipeGesture)
            
            let rightSwipeGesture = UISwipeGestureRecognizer(target : self, action : #selector(UserListVC.swipeGesture))
            rightSwipeGesture.direction = .right
            cellUser.addGestureRecognizer(rightSwipeGesture)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrUserList[indexPath.row].isClose == false {
            //Write code here
            
            //Redirect To Chat Screen
            self.redirectToChatScreen(userDetails: self.arrUserList[indexPath.row])
        }
        
        //Hide All Close Button
        self.hideAllCloseButton()
    }
    @objc func swipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            let view = swipeGesture.view
            let index = view?.tag ?? -1
            if index != -1 {
                if swipeGesture.direction == .right {
                    if self.arrUserList[index].isClose == true {
                        self.arrUserList[index].isClose = false
                        let indexPath = IndexPath(row: index, section: 0)
                        let cell = tblUserlist.cellForRow(at: indexPath) as! CellUserList
                        cell.hideCloseButton()
                    }
                } else if swipeGesture.direction == .left {
                    if self.arrUserList[index].isClose == false {
                        
                        //Hide All Close Button
                        self.hideAllCloseButton()
                        
                        self.arrUserList[index].isClose = true
                        let indexPath = IndexPath(row: index, section: 0)
                        let cell = tblUserlist.cellForRow(at: indexPath) as! CellUserList
                        cell.showCloseButton()
                    }
                }
            }
        }
    }
    func hideAllCloseButton() {
        var i = 0
        for data in self.arrUserList {
            if data.isClose == true {
                self.arrUserList[i].isClose = false
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = tblUserlist.cellForRow(at: indexPath) as? CellUserList {
                    cell.hideCloseButton()
                }
            }
            i = i + 1
        }
    }
    //Scroll To Bottom
    func scrollToBottom(isAnimated:Bool){
        DispatchQueue.main.async {
            
            if(self.arrUserList.count>0) {
                let indexPath = IndexPath(row: self.arrUserList.count-1, section: 0)
                self.tblUserlist.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
}
//MARK: - Redirect To Next Screen
extension UserListVC {
    func redirectToSettingsScreen() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func redirectToChatScreen(userDetails:ModelUserList) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        vc?.userDetails = userDetails
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
