//
//  ViewController.swift
//  VoiceToChat
//
//  Created by Shree on 31/03/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Speech
import AVKit

//MARK: - Chat View Controller
class ChatVC: UIViewController {

    //TODO: - Outlet Declaration
    @IBOutlet var tblChat: UITableView!
    @IBOutlet var imgSettings: UIImageView!
    @IBOutlet var sliderChangeFontSize: UISlider!
    @IBOutlet var txtMessage: UITextView!
    @IBOutlet var constraintHeightSendMessageBG: NSLayoutConstraint!
    @IBOutlet var constraintBottomSafeArea: NSLayoutConstraint!
    @IBOutlet var controlHideKeyboard: UIControl!
    @IBOutlet var controlSendMessage: UIControl!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var controlVoiceBG: UIControl!
    
    @IBOutlet var constraintHeightBannerAds: NSLayoutConstraint!
    @IBOutlet var viewRippleAnimationBG: UIView!
    
    @IBOutlet var lblChangeSize: UILabel!
    
    //TODO: - Variable Declaration
    var arrChatList = [ModelChat]()
    var arrAllChatData = [ModelChatWithDate]()
    
    var fontSize = Float(17)
    var isKeyboardOpen = false
    var strMessagePlaceholder = "Type a message"
    let colorTextMessagePlaceholder = UIColor.gray
    let colorTextMessage = UIColor.black
    var userDetails = ModelUserList.init(strUserName: "", userId: 0)
    var db:DBHelper = DBHelper()
    var keyboardHeight = 0
    let rippleLayer = RippleLayer()
    var isRecordingStart = false
    
    //Speech to text
    var strSpeechText = ""
    var strSpeechTextParssed = ""
    var timerSpeechToText:Timer!
    
    let speechRecognizer        = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest      : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask         : SFSpeechRecognitionTask?
    let audioEngine             = AVAudioEngine()
    
    var heightBannerView = 0
    
    //TODO: - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prepare UI
        self.prepareUI()
        
        //Prepare Data
        self.prepareData()
        
        //Show Interstitial Ads
        //GoogleAdMob.sharedInstance.showInterstitial()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblChangeSize.text = "Change size".localizeString()
    }
    func prepareUI() {
        
        self.sliderChangeFontSize.setValue(fontSize, animated: false)
        
        //Text View Message UI update
        txtMessage.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0);
        txtMessage.textColor = colorTextMessagePlaceholder
        txtMessage.text = strMessagePlaceholder
        
        imgSettings.setImageColor(color: .black)
        
        controlVoiceBG.layer.cornerRadius = 23
        
        //Ripple Layer
        rippleLayer.position = CGPoint(x: viewRippleAnimationBG.layer.bounds.midX, y: viewRippleAnimationBG.layer.bounds.midY);
        viewRippleAnimationBG.layer.addSublayer(rippleLayer)
        rippleLayer.zPosition = 1000
    }
    func prepareData() {
        
        //Set Keyboard Height
        self.setKeyboardHeight()
        
        self.lblTitle.text = userDetails.strUserName
        
        //Relaod Chat Data
        self.relaodChatData(isScrollToBottom: true)
        
        //Setup Speech
        self.setupSpeech()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bannerAdsReceived(notification:)), name: Notification.Name("bannerAdsReceived"), object: nil)
    }
    func updateFontSize() {
        
        self.tblChat.reloadData()
    }
    //Hide Keyboard
    func dismissKeyboard() {
        view.endEditing(true)
        isKeyboardOpen = false
        controlHideKeyboard.isHidden = true
        constraintBottomSafeArea.constant = 0
    }
    func relaodChatData(isScrollToBottom:Bool) {
        
        self.arrAllChatData.removeAll()
        self.arrChatList.removeAll()
        self.arrChatList = db.readChat(userId: userDetails.userId)
        
        var strDate = ""
        var arrTempChatData = [ModelChat]()
        for chatData in self.arrChatList {
                //arrAllChatData
            if strDate.length > 0 && strDate != chatData.strDate {
                self.arrAllChatData.append(ModelChatWithDate.init(strDate: strDate, arrChat: arrTempChatData))
                
                arrTempChatData.removeAll()
                arrTempChatData.append(chatData)
                strDate = chatData.strDate
            } else {
                arrTempChatData.append(chatData)
                strDate = chatData.strDate
            }
        }
        
        if arrTempChatData.count > 0 {
            self.arrAllChatData.append(ModelChatWithDate.init(strDate: strDate, arrChat: arrTempChatData))
        }
        
        self.tblChat.reloadData()
        
        if isScrollToBottom == true && self.arrAllChatData.count > 0 {
            self.scrollToBottom(isAnimated: true)
        }
    }
    func sendMessage() {
        var strMessage = txtMessage.text ?? ""
        strMessage = strMessage.removeWhiteSpace()
        
        if strMessage.length > 0 {
            
            txtMessage.text = ""
            
            let dateFormatter : DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = Date()
            let strDate = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "hh:mm a"
            let strTime = dateFormatter.string(from: date)
            
            //Insert Chat Info
            db.insertChatInfo(data: ModelChat.init(messageId: 0, strMessage: strMessage, strDate: strDate, strTime: strTime), userId: userDetails.userId)
            
            //Relaod Chat Data
            self.relaodChatData(isScrollToBottom: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                //Update Send Message Box
                self.updateSendMessageBox()
            })
            
            if self.isRecordingStart {
                //Setup Speech
                self.setupSpeech()
            }
        }
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        //Set Keyboard Height
        self.setKeyboardHeight()
        
        //Dismiss Keyboard
        self.dismissKeyboard()
        
        //Update Send Message Box
        self.updateSendMessageBox()
        
        self.tblChat.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name("changeAppOrientation"), object: nil)
    }
    func setKeyboardHeight() {
        var isPortrait = true
        switch UIDevice.current.orientation {
        case .portrait:
            if UIApplication.isDeviceWithSafeArea {
                self.keyboardHeight = 320
            } else {
                self.keyboardHeight = 270
            }
            break
        case .portraitUpsideDown:
            if UIApplication.isDeviceWithSafeArea {
                self.keyboardHeight = 320
            } else {
                self.keyboardHeight = 270
            }
            break
        case .landscapeLeft:
            if UIApplication.isDeviceWithSafeArea {
                self.keyboardHeight = 210
            } else {
                self.keyboardHeight = 210
            }
            isPortrait = false
            break
        case .landscapeRight:
            if UIApplication.isDeviceWithSafeArea {
                self.keyboardHeight = 210
            } else {
                self.keyboardHeight = 210
            }
            isPortrait = false
            break
        default:
            if UIApplication.isDeviceWithSafeArea {
                self.keyboardHeight = 320
            } else {
                self.keyboardHeight = 270
            }
            break
        }
        
        //Update Banner Ads Size
        self.updateBannerAdsSize(isPortrait: isPortrait)
    }
    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd-MM"
        return  dateFormatter.string(from: date!)
    }
    func startRecording() {
        
        self.setupSpeech()
        
        //Dismiss Keyboard
        self.dismissKeyboard()
        
        //Start Animation
        self.viewRippleAnimationBG.isHidden = false
        self.rippleLayer.startAnimation()
        self.controlVoiceBG.backgroundColor = UIColor.init(red: 250/255, green: 20/255, blue: 195/255, alpha: 1.0)
    }
    func stopRecording() {
        
        if isRecordingStart == true {
            
            //Stop Animation
            self.viewRippleAnimationBG.isHidden = true
            self.rippleLayer.stopAnimation()
            self.controlVoiceBG.backgroundColor = .clear
            
            if txtMessage.text.isEmpty {
                txtMessage.text = strMessagePlaceholder
                txtMessage.textColor = colorTextMessagePlaceholder
            }
        }
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
                            heightBannerView = 0
                            constraintHeightBannerAds.constant = 0
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
        
        self.setKeyboardHeight()
    }
}
//MARK: - Tapped Event
extension ChatVC {
    @IBAction func tappedOnBack(_ sender: Any) {
        
        //Redirect To Back
        self.redirectToBack()
    }
    @IBAction func tappedOnVoiceEnd(_ sender: Any) {
        
        if isRecordingStart == true {
             //Stop Recording
             self.stopRecording()
        } else {
            //Start Recording
            self.startRecording()
        }
        isRecordingStart = !isRecordingStart
    }
    @IBAction func tappedOnVoiceOutside(_ sender: Any) {
        
        //Stop Recording
        //self.stopRecording()
    }
    @IBAction func tappedOnVoiceStart(_ sender: Any) {
        
        //Start Recording
        //self.startRecording()
    }
    @IBAction func tappedOnHideKeyboard(_ sender: Any) {
        
        //Dismiss Keyboard
        self.dismissKeyboard()
    }
    @IBAction func tappedOnSend(_ sender: Any) {
        
        //Send Message
        self.sendMessage()
    }
    @IBAction func tappedOnSettings(_ sender: Any) {
        
        //Dismiss Keyboard
        self.dismissKeyboard()
        
        //Redirect To Settings Screen
        self.redirectToSettingsScreen()
    }
    @IBAction func changeFontSize(_ sender: Any) {
        
        let slider = sender as! UISlider
        let value = slider.value
        
        //Update Font Size
        fontSize = value
        self.updateFontSize()
    }
    @IBAction func tappedOnChangeOrientation(_ sender: Any) {
        
        switch UIDevice.current.orientation {
        case .portrait:
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            break
        case .portraitUpsideDown:
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            break
        case .landscapeLeft:
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            break
        case .landscapeRight:
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            break
        default:
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrAllChatData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrAllChatData[section].arrChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"CellChat" , for: indexPath) as! CellChat
        
        let data = self.arrAllChatData[indexPath.section].arrChat[indexPath.row]
        cell.lblMessage.font = UIFont.init(name: "Arial", size: CGFloat(fontSize))
        cell.setData(data: data)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let viewDateBG = UIView.init(frame: CGRect.init(x: (tableView.frame.width/2)-40, y: 10, width: 80, height: 30))
        viewDateBG.clipsToBounds = true
        viewDateBG.layer.cornerRadius = 5
        viewDateBG.backgroundColor = UIColor.init(red: 237/255, green: 245/255, blue: 255/255, alpha: 1.0)
        headerView.addSubview(viewDateBG)
        
        let strDate = self.arrAllChatData[section].strDate
        let strFinalDate = self.convertDateFormater(strDate)
        
        let lblTime = UILabel()
        lblTime.frame = CGRect.init(x: 0, y: 0, width: viewDateBG.frame.width, height: viewDateBG.frame.height)
        lblTime.text = strFinalDate
        lblTime.textAlignment = .center
        viewDateBG.addSubview(lblTime)
        return headerView
    }
}
//MARK: - Redirect To Next Screen
extension ChatVC {
    func redirectToBack() {
        self.navigationController?.popViewController(animated: true)
    }
    func redirectToSettingsScreen() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
//MARK:- UITextFieldDelegate
extension ChatVC:UITextViewDelegate {
    
    //UI Update Send Message Box
    func updateSendMessageBox() {
     
        let numLines = (txtMessage.contentSize.height / txtMessage.font!.lineHeight)
        let intNumberOfLines = Int(numLines)
        var totalNumberOfLines = 0
        if UIDevice.current.orientation.isLandscape {
            totalNumberOfLines = 3
        } else {
            totalNumberOfLines = 7
        }
        if(intNumberOfLines == 1) {
            
            constraintHeightSendMessageBG.constant = 50.0
        } else {
            
            if(intNumberOfLines < totalNumberOfLines) {
                constraintHeightSendMessageBG.constant = CGFloat((50 + (intNumberOfLines * 14)))
            }
        }
        
        //Text View Scroll To Bottom
        self.textViewScrollToBottom()
    }
    //Update Text Feild UI
    func updateTextFeildUI() {
        
        self.scrollToBottom(isAnimated: true)
        self.updateSendMessageBox()
    }
    //Scroll To Bottom
    func scrollToBottom(isAnimated:Bool){
        DispatchQueue.main.async {
            
            if(self.arrAllChatData.count>0) {
                let indexPath = IndexPath(row: self.arrAllChatData[self.arrAllChatData.count-1].arrChat.count-1, section: self.arrAllChatData.count-1)
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        isKeyboardOpen = true
        controlHideKeyboard.isHidden = false
        constraintBottomSafeArea.constant = CGFloat(keyboardHeight-heightBannerView)
        if textView.textColor == colorTextMessagePlaceholder {
            textView.text = ""
            textView.textColor = colorTextMessage
        }
        
        //Update Send Message Box
        self.updateSendMessageBox()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = strMessagePlaceholder
            textView.textColor = colorTextMessagePlaceholder
        }
        //Update Send Message Box
        self.updateSendMessageBox()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        //Check textview is empty or not
        if updatedText.isEmpty {

            textView.text = strMessagePlaceholder
            textView.textColor = colorTextMessagePlaceholder

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        } else if textView.textColor == colorTextMessagePlaceholder && !text.isEmpty {

            //When textview is not empty
            textView.textColor = colorTextMessage
            textView.text = text

        } else {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                //Update Send Message Box
                self.updateSendMessageBox()
            })

            return true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            //Update Send Message Box
            self.updateSendMessageBox()
        })
        return false
    }
    func textViewScrollToBottom() {
        if txtMessage.text.count > 10 {
            let bottomRange = NSMakeRange(self.txtMessage.text.count - 1, 1)
            self.txtMessage.scrollRangeToVisible(bottomRange)
        }
    }
}
//MARK: - SFSpeechRecognizerDelegate
extension ChatVC: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("speechRecognizer : availabilityDidChange")
        if available {
            //self.btnStart.isEnabled = true
        } else {
            //self.btnStart.isEnabled = false
        }
    }
    @objc func setupSpeech() {

        self.speechRecognizer?.delegate = self

        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            var isButtonEnabled = false
            var strAlertMessage = ""

            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                break
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                strAlertMessage = "User denied access to speech recognition"
                break
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                strAlertMessage = "Speech recognition restricted on this device"
                break
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
                strAlertMessage = "Speech recognition not yet authorized"
                break
            }

            OperationQueue.main.addOperation() {
                //self.btnStart.isEnabled = isButtonEnabled
                if(isButtonEnabled == true) {
                    //Start Speech Recording
                    self.startSpeechRecording()
                } else {
                    //Show Alert
                    self.showAlert(title: "Alert", message: strAlertMessage, buttonName: "Cancel") { (status) in
                        
                    }
                }
            }
        }
    }
    func startSpeechRecording() {

        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        self.audioEngine.stop()
        
        if self.recognitionRequest != nil {
            self.recognitionRequest = nil
        }
        if self.recognitionTask != nil {
            self.recognitionTask = nil
        }
        
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false

            if result != nil {
                /*if(result?.transcriptions.count ?? 0>0) {
                    let finalTranscriptions = result?.transcriptions[(result?.transcriptions.count ?? 0)-1]
                    var strSpeechWord = finalTranscriptions?.formattedString
                    strSpeechWord = strSpeechWord?.uppercased()
                    
                    let parsed = strSpeechWord?.replacingOccurrences(of: self.strSpeechText, with: "")
                    
                    self.strSpeechText = strSpeechWord ?? ""
                    print("Final Word : ",strSpeechWord)
                    print("Final Word parsed : ",parsed)
                } else {
                    
                }*/
                
                //self.txtViewDescription.text = result?.bestTranscription.formattedString
                var strSpeechWord = (result?.bestTranscription.formattedString ?? "") + ""
                strSpeechWord = strSpeechWord.uppercased()
                strSpeechWord = strSpeechWord.trimmingCharacters(in: .whitespaces)
                
                //Set Spoke Word
                self.setSpokeWord(updatedText: strSpeechWord)
                
//                if(self.strSpeechText != strSpeechWord) {
//                    let strParsed = strSpeechWord.replacingOccurrences(of: self.strSpeechText, with: "").trimmingCharacters(in: .whitespaces)
//                    //strSpeechWord = strSpeechWord.uppercased()
//                    self.strSpeechText = strSpeechWord
//                    self.strSpeechTextParssed = strParsed
//
//                    print("SPEECH WORD PARSED :",strParsed)
//                    print("SPEECH WORD :",strSpeechWord)
//                    self.txtMessage.text = strSpeechWord
//
//                    if(self.timerSpeechToText != nil) {
//                        self.timerSpeechToText.invalidate()
//                    }
//                    self.timerSpeechToText = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.checkSpokeWord), userInfo: nil, repeats: false)
//                }
                isFinal = (result?.isFinal)!
            }

            //if error != nil || isFinal {

                //self.audioEngine.stop()
                //inputNode.removeTap(onBus: 0)

                //self.recognitionRequest = nil
                //self.recognitionTask = nil

                //self.btnStart.isEnabled = true
            //}
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()

        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

        print("Say something, I'm listening!")
    }
    @objc func checkSpokeWord() {
        print("Check Spoke Word")
        
        print("SPEECH TEXT PARSSED :",self.strSpeechTextParssed)
    }
    
    func setSpokeWord(updatedText:String) {
        
        if self.isRecordingStart {
            
            //Check textview is empty or not
            if updatedText.isEmpty {

                txtMessage.text = strMessagePlaceholder
                txtMessage.textColor = colorTextMessagePlaceholder

                txtMessage.selectedTextRange = txtMessage.textRange(from: txtMessage.beginningOfDocument, to: txtMessage.beginningOfDocument)

            } else {

                let strMessage = updatedText.capitalizingFirstLetter()
                
                //When textview is not empty
                txtMessage.textColor = colorTextMessage
                txtMessage.text = strMessage
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                //Update Send Message Box
                self.updateSendMessageBox()
            })
        }
    }
}
