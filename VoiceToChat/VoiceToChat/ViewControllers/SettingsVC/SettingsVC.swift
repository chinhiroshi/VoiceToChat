//
//  SettingsVC.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit
import MessageUI
import IAPurchaseManager

//MARK: - Settings View Controller
class SettingsVC: UIViewController {

    //TODO: - Outlet declaration
    @IBOutlet var lblSpeechToText: UILabel!
    @IBOutlet var lblLangSpeechToText: UILabel!
    
    @IBOutlet var lblChangeLanguage: UILabel!
    @IBOutlet var lblLangChange: UILabel!
    
    @IBOutlet var lblSentenceRecognition: UILabel!
    @IBOutlet var lblSentenceRecognitionCounter: UILabel!
    
    @IBOutlet var controlRestorePurchse: UIControl!
    @IBOutlet var lblRestorePurchse: UILabel!
    
    @IBOutlet var controlBuyPremiumFeature: UIControl!
    @IBOutlet var lblPriceBuyPremiumFeature: UILabel!
    @IBOutlet var lblBuyPremiumFeature: UILabel!
    
    @IBOutlet var constraintHeightBottomView: NSLayoutConstraint!
    
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblBuyPremiumFeatures: UILabel!
    
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var pickerNumber: UIPickerView!
    @IBOutlet var constraintHeightPickerNumber: NSLayoutConstraint!
    
    //TODO: - Variable Declaration
    var arrSentenceNumber:[Double] = [0.5,1.0,2.0,3.0]
    var secondsForSpeechRecognization = 0.5
    var loaderView: LoaderView?
    
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
        
        self.pickerNumber.selectRow(Int(secondsForSpeechRecognization), inComponent: 0, animated: true)
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
        
        //Check Device Orientation
        self.checkDeviceOrientation()
        
        self.lblSpeechToText.text = "Speech to text language".localizeString()
        self.lblChangeLanguage.text = "Change language".localizeString()
        self.lblSentenceRecognition.text = "Sentence recognition".localizeString()
        self.lblContact.text = "Contact".localizeString()
        self.lblBuyPremiumFeatures.text = "Buy premium feature".localizeString()
        self.lblRestorePurchse.text = "Restore Purchses".localizeString()
        self.btnDone.setTitle("Done".localizeString(), for: .normal)
        
        let sentenceReco = UserInfo.sharedInstance.getSentencesRecognization()
        if sentenceReco == 0.5 {
            secondsForSpeechRecognization = 0.5
        } else if sentenceReco == 1.0 {
            secondsForSpeechRecognization = 1.0
        } else if sentenceReco == 2.0 {
            secondsForSpeechRecognization = 2.0
        } else if sentenceReco == 3.0 {
            secondsForSpeechRecognization = 3.0
        }
        
        self.pickerNumber.reloadAllComponents()
        self.lblSentenceRecognitionCounter.text = "\(secondsForSpeechRecognization) " + "seconds".localizeString()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bannerAdsReceived(notification:)), name: Notification.Name("bannerAdsReceived"), object: nil)
        
        self.lblPriceBuyPremiumFeature.text = ""
        IAPManager.shared.loadProducts(productIds: [strInAppPurchase]) { (products, error) -> Void in
            if error != nil {
                
            } else {
                if let product = products?.first {
                    // Get its price from iTunes Connect
                    let numberFormatter = NumberFormatter()
                    numberFormatter.formatterBehavior = .behavior10_4
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = product.priceLocale
                    if let price = numberFormatter.string(from: product.price) {
                        self.lblPriceBuyPremiumFeature.text = String(describing: price)
                    }
                }
            }
        }
        
        //Check Purchse Feature
        self.checkPurchseFeature()
    }
    func checkPurchseFeature() {
        let isProductPurchased = IAPManager.shared.isProductPurchased(productId: strInAppPurchase)
        if isProductPurchased {
            
            controlRestorePurchse.alpha = 0.4
            controlRestorePurchse.isUserInteractionEnabled = false
            
            controlBuyPremiumFeature.alpha = 0.4
            controlBuyPremiumFeature.isUserInteractionEnabled = false
            lblBuyPremiumFeature.text = "Purchsed premium feature".localizeString()
            
            //Hide Banner View
            GoogleAdMob.sharedInstance.hideBannerView()
            
        } else {
            print("isProductPurchased : NO")
            
            controlRestorePurchse.alpha = 1.0
            controlRestorePurchse.isUserInteractionEnabled = true
            
            controlBuyPremiumFeature.alpha = 1.0
            controlBuyPremiumFeature.isUserInteractionEnabled = true
            lblBuyPremiumFeature.text = "Buy premium feature".localizeString()
        }
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
                        constraintHeightBottomView.constant = 50
                    } else {
                        if isIphoneXOrLonger == true {
                            constraintHeightBottomView.constant = 0
                        } else {
                            constraintHeightBottomView.constant = 50
                        }
                    }
                } else {
                    constraintHeightBottomView.constant = 0
                }
            } else {
                constraintHeightBottomView.constant = 0
            }
        } else {
            constraintHeightBottomView.constant = 0
        }
    }
    @objc func bannerAdsReceived(notification: Notification) {
        
        self.checkDeviceOrientation()
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
            
        } else if strLang == "zh-Hans" {
            self.lblLangChange.text = "Chinese"
            
        } else {
            self.lblLangChange.text = "Japanese"
        }
    }
    func updateSpeechToTextLanguage() {
        
        let strLang = UserDefaults.Main.string(forKey: .speechToTextLanguage)
        if strLang == "en" {
            self.lblLangSpeechToText.text = "English"
            
        } else if strLang == "zh-Hans" {
            self.lblLangSpeechToText.text = "Chinese"
            
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
        let chinese = UIAlertAction(title: "Chinese", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("zh-Hans", forKey: .changeLanguage)
            UserDefaults.standard.synchronize()
            
            //Prepare Data
            self.prepareData()
        })
        let cancel = UIAlertAction(title: "Cancel".localizeString(), style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(english)
        dialogMessage.addAction(japanese)
        dialogMessage.addAction(chinese)
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
        let chinese = UIAlertAction(title: "Chinese", style: .default, handler: { (action) -> Void in
            
            UserDefaults.Main.set("zh-Hans", forKey: .speechToTextLanguage)
            UserDefaults.standard.synchronize()
            
            //Update Speech To Text Language
            self.updateSpeechToTextLanguage()
        })
        let cancel = UIAlertAction(title: "Cancel".localizeString(), style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(english)
        dialogMessage.addAction(japanese)
        dialogMessage.addAction(chinese)
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
        
        showLoaderView(with: "")
        IAPManager.shared.purchaseProduct(productId: strInAppPurchase) { (error) -> Void in
            if error == nil {
                print("successful purchase!")
            } else {
                print("something wrong..")
                print(error ?? "NIL")
            }
            
            //Check Purchse Feature
            self.checkPurchseFeature()
            
            //Hide Loader
            self.hideLoader()
        }
    }
    @IBAction func tappedOnRestorePurchse(_ sender: Any) {
        
        showLoaderView(with: "")
        IAPManager.shared.restoreCompletedTransactions { (error) in
            print("error : ",error ?? "NIL")
            if error != nil {
                
            } else {
                
            }
            
            //Check Purchse Feature
            self.checkPurchseFeature()
            
            //Hide Loader
            self.hideLoader()
        }
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
        secondsForSpeechRecognization = self.arrSentenceNumber[row]
    }
}
// MARK: - Show / Hide loader for purchase and restore
extension SettingsVC {
    func showLoaderView(with title:String) {
        loaderView = LoaderView.instanceFromNib()
        loaderView?.lblLoaderTitle.text = title
        loaderView?.frame = self.view.frame
        self.view.addSubview(loaderView!)
    }

    func hideLoader() {
        if loaderView != nil {
            loaderView?.removeFromSuperview()
        }
    }
}
