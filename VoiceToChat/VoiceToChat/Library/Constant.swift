//
//  Constant.swift
//  VoiceToChat
//
//  Created by Shree on 03/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

//MARK: - Currnt User
var currentUser = ModelUserList.init(strUserName: "", userId: 0)
var strContactEmail = "hiroshi.chin@gmail.com"

var strInAppPurchase = "com.voicetochat.voicetochat.full"

var googleAdMobBanner = "ca-app-pub-7265780855429088/7725027997"

//MARK: - App Name
var appName = "Voice To Chat"


var hasTopNotch: Bool {
    if #available(iOS 13.0,  *) {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
    }else{
     return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}

var isIphoneXOrLonger: Bool {
    // 812.0 / 375.0 on iPhone X, XS.
    // 896.0 / 414.0 on iPhone XS Max, XR.
    return UIScreen.main.bounds.height / UIScreen.main.bounds.width >= 896.0 / 414.0
}

//MARK: - Screen Size
struct ScreenSize {
    
    static let width         = UIScreen.main.bounds.size.width
    static let height        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.width, ScreenSize.height)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.width, ScreenSize.height)
}
