//
//  DateExtension.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
