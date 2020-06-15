//
//  UserInfo.swift
//  VoiceToChat
//
//  Created by Shree on 30/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

class UserInfo: NSObject {
    //MARK: - Shared Instance
    static let sharedInstance : UserInfo = {
        let instance = UserInfo()
        return instance
    }()
    
    //MARK: - Set/Get Sentences Recognization
    func getSentencesRecognization() -> Double {
        if let seconds:Double = UserDefaults.standard.double(forKey: "SentencesRecognization") as Double? {
            return seconds
        }
        return 0.0
    }
    func setSentencesRecognization(data: Double) {
        
        UserDefaults.standard.set(data, forKey: "SentencesRecognization")
        UserDefaults.standard.synchronize()
    }
}
