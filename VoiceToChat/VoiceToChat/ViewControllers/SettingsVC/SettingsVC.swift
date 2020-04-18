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
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblHelps: UILabel!
    @IBOutlet var lblBuyPremiumFeatures: UILabel!
    
    //TODO: - Variable Declaration
    
    
    //TODO: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //Prepare UI
        self.prepareUI()
        
        //Prepare Data
        self.prepareData()
    }
    func prepareUI() {
        
        
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
        self.lblHelps.text = "Helps".localizeString()
        self.lblBuyPremiumFeatures.text = "Buy premium feature".localizeString()
        
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
}
//MARK: - Tapped Event
extension SettingsVC {
    @IBAction func tappedOnBack(_ sender: Any) {
        
        //Redirect To Back Screen
        self.redirectToBackScreen()
    }
    @IBAction func tappedOnSpeechToTextLang(_ sender: Any) {
        
        //Show Speech To Text Language Popup
        //self.showSpeechToTextLanguagePopup()
    }
    @IBAction func tappedOnChangeLanguage(_ sender: Any) {
        
        //Show Change Language Popup
        self.showChangeLanguagePopup()
    }
    @IBAction func tappedOnSentenseRecognization(_ sender: Any) {
        
    }
    @IBAction func tappedOnContact(_ sender: Any) {
        
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    @IBAction func tappedOnHelps(_ sender: Any) {
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
