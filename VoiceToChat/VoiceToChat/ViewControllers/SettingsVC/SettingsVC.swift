//
//  SettingsVC.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit
import MessageUI

//MARK: - Settings View Controller
class SettingsVC: UIViewController {

    //TODO: - Outlet declaration
    @IBOutlet var lblSpeechToText: UILabel!
    @IBOutlet var lblLangSpeechToText: UILabel!
    
    @IBOutlet var lblChangeLanguage: UILabel!
    @IBOutlet var lblLangChange: UILabel!
    
    @IBOutlet var lblSentenceRecognition: UILabel!
    @IBOutlet var lblSentenceRecognitionCounter: UILabel!
    
    @IBOutlet var constraintHeightBottomView: NSLayoutConstraint!
    
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblBuyPremiumFeatures: UILabel!
    
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var pickerNumber: UIPickerView!
    @IBOutlet var constraintHeightPickerNumber: NSLayoutConstraint!
    
    //TODO: - Variable Declaration
    var arrSentenceNumber:[Int] = [1,2,3]
    var secondsForSpeechRecognization = 3
    
    //TODO: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //Prepare UI
        self.prepareUI()
        
        //Prepare Data
        self.prepareData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pickerNumber.selectRow(secondsForSpeechRecognization-3, inComponent: 0, animated: true)
    }
    func prepareUI() {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: false)
        
    }
    func prepareData() {
        
        //Update Change Language Text
        self.updateChangeLanguageText()
        
        //Update Speech To Text Language
        self.updateSpeechToTextLanguage()
        
        self.lblSpeechToText.text = "Speech to text language".localizeString()
        self.lblChangeLanguage.text = "Change language".localizeString()
        self.lblSentenceRecognition.text = "Sentence recognition".localizeString()
        self.lblContact.text = "Contact".localizeString()
        self.lblBuyPremiumFeatures.text = "Buy premium feature".localizeString()
        self.btnDone.setTitle("Done".localizeString(), for: .normal)
        
        secondsForSpeechRecognization = UserInfo.sharedInstance.getSentencesRecognization()
        if secondsForSpeechRecognization == 0 {
           secondsForSpeechRecognization = 3
        }
        self.pickerNumber.reloadAllComponents()
        self.lblSentenceRecognitionCounter.text = "\(secondsForSpeechRecognization) " + "seconds".localizeString()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bannerAdsReceived(notification:)), name: Notification.Name("bannerAdsReceived"), object: nil)
        
        if UserDefaults.Main.bool(forKey: .isShowBannerAds) {
            self.constraintHeightBottomView.constant = 50
        }
        
        
    }
    @objc func bannerAdsReceived(notification: Notification) {
        
        self.constraintHeightBottomView.constant = 50
    }
    func showSelectSentencePopup(isAnimated:Bool) {
        
        self.constraintHeightPickerNumber.constant = 200
        if isAnimated {
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    func hideSelectSentencePopup(isAnimated:Bool) {
        self.constraintHeightPickerNumber.constant = 0
        if isAnimated {
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    func updateChangeLanguageText() {
        let strLang = UserDefaults.Main.string(forKey: .changeLanguage)
        
        if strLang == "en" {
            self.lblLangChange.text = "English"
        } else {
            self.lblLangChange.text = "Japanese"
        }
    }
    func updateSpeechToTextLanguage() {
        
        let strLang = UserDefaults.Main.string(forKey: .speechToTextLanguage)
        if strLang == "en" {
            self.lblLangSpeechToText.text = "English"
        } else {
            self.lblLangSpeechToText.text = "Japanese"
        }
    }
    func showChangeLanguagePopup() {
        let dialogMessage = UIAlertController(title:nil, message: "Please select language".localizeString(), preferredStyle: .actionSheet)
        let english = UIAlertAction(title: "English", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("en", forKey: .changeLanguage)
            UserDefaults.standard.synchronize()
            
            //Prepare Data
            self.prepareData()
        })
        let japanese = UIAlertAction(title: "Japanese", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("ja", forKey: .changeLanguage)
            UserDefaults.standard.synchronize()
            
            //Prepare Data
            self.prepareData()
        })
        let cancel = UIAlertAction(title: "Cancel".localizeString(), style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(english)
        dialogMessage.addAction(japanese)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    func showSpeechToTextLanguagePopup() {
        let dialogMessage = UIAlertController(title:nil, message: "Please select language for speech to text".localizeString(), preferredStyle: .actionSheet)
        let english = UIAlertAction(title: "English", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("en", forKey: .speechToTextLanguage)
            UserDefaults.standard.synchronize()
            
            //Update Speech To Text Language
            self.updateSpeechToTextLanguage()
        })
        let japanese = UIAlertAction(title: "Japanese", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("ja", forKey: .speechToTextLanguage)
            UserDefaults.standard.synchronize()
            
            //Update Speech To Text Language
            self.updateSpeechToTextLanguage()
        })
        let cancel = UIAlertAction(title: "Cancel".localizeString(), style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(english)
        dialogMessage.addAction(japanese)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    func configureMailComposer() -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([strContactEmail])
        mailComposeVC.setSubject("Contact Us")
        return mailComposeVC
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        NotificationCenter.default.post(name: Notification.Name("changeAppOrientation"), object: nil)
    }
    func contactUs() {

        let subject = "Contact Us"
        let bodyText = ""

        if MFMailComposeViewController.canSendMail() {

            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate

            mailComposerVC.setToRecipients([strContactEmail])
            mailComposerVC.setSubject(subject)
            mailComposerVC.setMessageBody(bodyText, isHTML: false)

            self.present(mailComposerVC, animated: true, completion: nil)

        } else {
            print("Device not configured to send emails, trying with share ...")

            let coded = "mailto:\(strContactEmail)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!) {
                
                if #available(iOS 10.0, *) {
                    if UIApplication.shared.canOpenURL(emailURL) {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                            if !result {
                                print("Unable to send email.")
                            }
                        })
                    } else {
                        self.showMessageView(title: appName, message: "Device not configured to send email.", theme: .error)
                    }
                }
                else {
                    UIApplication.shared.openURL(emailURL as URL)
                }
            }
        }
    }
}
//MARK: - Tapped Event
extension SettingsVC {
    @IBAction func tappedOnDone(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
    }
    @IBAction func tappedOnBack(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
        
        //Redirect To Back Screen
        self.redirectToBackScreen()
    }
    @IBAction func tappedOnSpeechToTextLang(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
        
        //Show Speech To Text Language Popup
        self.showSpeechToTextLanguagePopup()
    }
    @IBAction func tappedOnChangeLanguage(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
        
        //Show Change Language Popup
        self.showChangeLanguagePopup()
    }
    @IBAction func tappedOnSentenseRecognization(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
        
        //Show Select Sentence Popup
        self.showSelectSentencePopup(isAnimated: true)
    }
    @IBAction func tappedOnContact(_ sender: Any) {
        
        //Hide Select Sentence Popup
        self.hideSelectSentencePopup(isAnimated: true)
        
        self.contactUs()
    }
    @IBAction func tappedOnBuyPremiumFeatures(_ sender: Any) {
        
    }
}
//MARK: - Redirect To Next Screen
extension SettingsVC {
    func redirectToBackScreen() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension SettingsVC:MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
//MARK: - UIPickerViewDelegate
extension SettingsVC:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrSentenceNumber.count
    }
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(self.arrSentenceNumber[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.lblSentenceRecognitionCounter.text = "\(self.arrSentenceNumber[row]) " + "seconds".localizeString()
        UserInfo.sharedInstance.setSentencesRecognization(data: self.arrSentenceNumber[row])
        secondsForSpeechRecognization = row
    }
}
