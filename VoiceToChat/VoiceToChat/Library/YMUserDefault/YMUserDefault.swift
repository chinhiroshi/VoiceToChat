
//
//  YMUserDefault.swift
//  UserDefaultDemo
//
// Referrence : https://medium.com/swift-programming/swift-userdefaults-protocol-4cae08abbf92#.k1h4qyz85


import Foundation

protocol KeyNamespaceable {

}

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }
    
    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}


// MARK: -  User Defaults Types
protocol UserDefaultable : KeyNamespaceable {
    associatedtype BoolDefaultKey : RawRepresentable
    associatedtype FloatDefaultKey : RawRepresentable
    associatedtype StringDefaultKey : RawRepresentable
    associatedtype IntegerDefaultKey : RawRepresentable
    associatedtype ObjectDefaultKey : RawRepresentable
    associatedtype DoubleDefaultKey : RawRepresentable
    associatedtype URLDefaultKey : RawRepresentable
    
}

extension UserDefaultable where BoolDefaultKey.RawValue == String,FloatDefaultKey.RawValue == String,StringDefaultKey.RawValue == String, IntegerDefaultKey.RawValue == String,ObjectDefaultKey.RawValue == String,DoubleDefaultKey.RawValue == String,URLDefaultKey.RawValue == String {
    
    static func set(_ bool: Bool, forKey key: BoolDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(bool, forKey: key)
    }
    
    static func bool(forKey key: BoolDefaultKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func set(_ float: Float, forKey key: FloatDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(float, forKey: key)
    }
    
    static func float(forKey key: FloatDefaultKey) -> Float {
        let key = namespace(key)
        return UserDefaults.standard.float(forKey: key)
    }
    static func set(_ string: String, forKey key: StringDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(string, forKey: key)
    }
    
    static func string(forKey key: StringDefaultKey) -> String {
        let key = namespace(key)
        return UserDefaults.standard.string(forKey:key) == nil ? "" :  UserDefaults.standard.string(forKey:key)!
        // When getting nil its return double quotes
    }
    
    static func set(_ integer: Int, forKey key: IntegerDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(integer, forKey: key)
    }
    
    static func integer(forKey key: IntegerDefaultKey) -> Int {
        let key = namespace(key)
        return UserDefaults.standard.integer(forKey: key)
    }
    static func set(_ object: Any, forKey key: ObjectDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(object, forKey: key)
    }
    
    static func object(forKey key: ObjectDefaultKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func set(_ double: Double, forKey key: DoubleDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(double, forKey: key)
    }
    
    static func double(forKey key: DoubleDefaultKey) -> Double {
        let key = namespace(key)
        return UserDefaults.standard.double(forKey: key)
    }
    
    static func set(_ url: URL, forKey key: URLDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(url, forKey: key)
    }
    
    static func url(forKey key: URLDefaultKey) -> URL? {
        let key = namespace(key)
        return UserDefaults.standard.url(forKey: key)
    }
    
    
    // For Remove User Default
    static func removeObj(forKey key:BoolDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:FloatDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:StringDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:IntegerDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:ObjectDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:DoubleDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
    static func removeObj(forKey key:URLDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey:key)
    }
}
extension UserDefaults {
    struct Main : UserDefaultable {
        private init() { }
        
        enum BoolDefaultKey : String {
            case boolKey
            case isBannerAdsReceived
            case isRemovedAds
            case isShowBannerAds
        }
        
        enum FloatDefaultKey:String {
            case floatKey
        }
        
        enum DoubleDefaultKey: String {
            case doubleKey
        }
        
        enum IntegerDefaultKey: String {
            case intKey
            case int_chat_counter
        }
        
        enum StringDefaultKey: String {
            case stringKey
            case changeLanguage
            case speechToTextLanguage
            case last_date
        }
        
        enum URLDefaultKey: String {
            case urlKey
        }
        
        enum ObjectDefaultKey: String {
            case objKey
            case currentUser
        }
    }
}

