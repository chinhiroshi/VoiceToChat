
import Foundation
import UIKit
import CoreTelephony

// MARK: - Registration Validation
extension String {
    
    static func validateStringValue(str:String?) -> Bool{
        var strNew = ""
        if str != nil{
            strNew = str!.trimWhiteSpace(newline: true)
        }
        if str == nil || strNew == "" || strNew.count == 0  {  return true  }
        else  {  return false  }
    }
    
    static func validatePassword(str:String?) -> Bool{
        if str == nil || str == "" || str!.count < 6  {  return true  }
        else  {  return false  }
    }
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[0-9a-z_.]{3,15}" //^[a-zA-Z0-9_]{3,15}$
        let temp = NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
        return temp
    }
    
    func isValidName() -> Bool{
        let nameRegix = "(?:[\\p{L}\\p{M}]|\\d)"
        return NSPredicate(format: "SELF MATCHES %@", nameRegix).evaluate(with: self)
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let temp = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        return temp
    }
    
    func validPhoneNumber() -> Bool {
        let phoneNumberRegex = "^[6-9]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: self)
        return phoneTest
    }

    func validateContact() -> Bool{
//        let contactRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let contactRegEx = "^[0-9]{10,10}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
    
    func validateBankAccNo() -> Bool{
        let accountRegEx = "^[0-9]{10,15}$"
        let accountTest = NSPredicate(format:"SELF MATCHES %@", accountRegEx)
        return accountTest.evaluate(with: self)
    }
}

// MARK: - Character check
extension String {
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }
    }
    
    func removeSpecial(_ character: String) -> String {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(self.filter {okayChars.contains($0) })
    }
}
// MARK: - Layout
extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func isEqual(str: String) -> Bool {
        if self.compare(str) == ComparisonResult.orderedSame{
            return true
        }else{
            return false
        }
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func singleLineHeight(font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func WidthWithNoConstrainedHeight(font: UIFont) -> CGFloat {
        let width = CGFloat.greatestFiniteMagnitude
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func stringSize(with font: UIFont) -> CGSize {
        let width = CGFloat.greatestFiniteMagnitude
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
}

// MARK: - For MRZ Data Processing
extension String {
    
    func replace(target: String, with: String) -> String {
        return self.replacingOccurrences(of: target, with: with, options: .literal, range: nil)
    }
    
    func toNumber() -> String {
        return self
            .replace(target: "O", with: "0")
            .replace(target: "Q", with: "0")
            .replace(target: "U", with: "0")
            .replace(target: "D", with: "0")
            .replace(target: "I", with: "1")
            .replace(target: "Z", with: "2")
            .replace(target: "A", with: "4")
            .replace(target: "S", with: "5")
            .replace(target: "S", with: "8")
            .replace(target: "H", with: "4")
    }
    
    func toString() -> String{
        return self
            .replace(target: "0", with: "O")
            .replace(target: "0", with: "Q")
            .replace(target: "0", with: "U")
            .replace(target: "0", with: "D")
            .replace(target: "1", with: "I")
            .replace(target: "2", with: "Z")
            .replace(target: "4", with: "A")
            .replace(target: "5", with: "S")
            .replace(target: "8", with: "S")
    }
    
    func subString(_ from: Int, to: Int) -> String {
        let f: String.Index = self.index(self.startIndex, offsetBy: from)
        let t: String.Index = self.index(self.startIndex, offsetBy: to + 1)
        return self.substring(with: f..<t)
    }
}

//MARK: - String Extension
extension String {
    
    //Remove white space in string
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    //Check string is number or not
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    //Check string is Float or not
    var isFloat : Bool {
        get{
     
            if Float(self) != nil {
                return true
            }else {
                return false
            }
        }
    }
    
    //Format Number If Needed
    func formatNumberIfNeeded() -> String {
        
        let charset = CharacterSet(charactersIn: "0123456789.,")
        if self.rangeOfCharacter(from: charset) != nil {
            
            let currentTextWithoutCommas:NSString = (self.replacingOccurrences(of: ",", with: "")) as NSString
            
            if currentTextWithoutCommas.length < 1 {
                return ""
            }
            let numberFormatter: NumberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            
            let numberFromString: NSNumber = numberFormatter.number(from: currentTextWithoutCommas as String)!
            let formattedNumberString: NSString = numberFormatter.string(from: numberFromString)! as NSString
            
            let convertedString:String = String(formattedNumberString)
            return convertedString
            
        } else {
            
            return self
        }
    }
    //MARK: - Check Contains Capital Letter
    func isContainsCapital() -> Bool {

        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let textTest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalResult = textTest.evaluate(with: self)
        return capitalResult
    }
    //MARK: - Check Contains Number Letter
    func isContainsNumber() -> Bool {
        
        let numberRegEx  = ".*[0-9]+.*"
        let textTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberResult = textTest.evaluate(with: self)
        return numberResult
    }
    //MARK: - Check Contains Special Character
    func isContainsSpecialCharacter() -> Bool {
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let textTest = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialResult = textTest.evaluate(with: self)
        return specialResult
    }
    //MARK: - Formate phone number
    func formatPhoneNumber() -> String {
        
        // Remove any character that is not a number
        let numbersOnly = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return ""
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return ""
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return ""
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return ""
        }
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    //Number Suffix
    func numberSuffix(from number: Int) -> String {
        
        switch number {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
    
    func base64ToImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self) else { return nil }
        return UIImage(data: imageData)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

//MARK: - Localization
extension String {
    
    func localizeString () -> String {
        
        let strLang = UserDefaults.Main.string(forKey: .changeLanguage)
        let path = Bundle.main.path (forResource: strLang, ofType: "lproj")
        let languageBundle = Bundle (path: path!)
        return languageBundle! .localizedString (forKey: self, value: "", table: nil)
    }
}
