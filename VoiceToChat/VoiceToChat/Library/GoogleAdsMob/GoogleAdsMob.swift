import UIKit
import GoogleMobileAds

//MARK: - Google Ads Unit ID
struct GoogleAdsUnitID {
    
    //Google Test Unit ID
    struct Test {
        static var strBannerAdsID = "ca-app-pub-3940256099942544/2934735716"
        static var strInterstitialAdsID = "ca-app-pub-3940256099942544/4411468910"
    }
    
    //Google Live admob Unit ID
    struct Live {
        static var strBannerAdsID = "ca-app-pub-3940256099942544/2934735716"
        static var strInterstitialAdsID = "ca-app-pub-3940256099942544/4411468910"
    }
}

//MARK: - Banner View Size
struct BannerViewSize {
    
    static var screenWidth = UIScreen.main.bounds.size.width
    static var screenHeight = UIScreen.main.bounds.size.height
    static var height = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50))
}

//MARK: - Create GoogleAdMob Class
class GoogleAdMob:NSObject, GADInterstitialDelegate, GADBannerViewDelegate {
    
    //MARK: - Shared Instance
    static let sharedInstance : GoogleAdMob = {
        let instance = GoogleAdMob()
        return instance
    }()
    
//MARK: - Variable
    private var isBannerViewDisplay = false
    
    private var isInitializeBannerView = false
    private var isInitializeInterstitial = false
    
    private var isBannerLiveID = false
    private var isInterstitialLiveID = false
    
    private var interstitialAds: GADInterstitial!
    private var bannerView: GADBannerView!

//MARK: - Create Banner View
    func initializeBannerView(isLiveUnitID:Bool) {
        
        self.isInitializeBannerView = true
        self.isBannerLiveID = isLiveUnitID
        self.createBannerView()
        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeAppOrientation(notification:)), name: Notification.Name("changeAppOrientation"), object: nil)
        
    }
    @objc private func createBannerView() {
        
        print("GoogleAdMob : create")
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBannerView), object: nil)
            self.perform(#selector(createBannerView), with: nil, afterDelay: 0.5)
        } else {
            
            isBannerViewDisplay = true
            let notchHeight = hasTopNotch == true ? CGFloat(34):CGFloat(0)
            bannerView = GADBannerView(frame: CGRect(
                x:0 ,
                y:BannerViewSize.screenHeight - BannerViewSize.height - notchHeight ,
                width:BannerViewSize.screenWidth ,
                height:BannerViewSize.height))
            
            if self.isBannerLiveID == false {
                
                self.bannerView.adUnitID = GoogleAdsUnitID.Test.strBannerAdsID
            } else {
                
                self.bannerView.adUnitID = GoogleAdsUnitID.Live.strBannerAdsID
            }
            
            self.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            self.bannerView.delegate = self
            self.bannerView.backgroundColor = .clear
            self.bannerView.load(GADRequest())
            self.bannerView.isUserInteractionEnabled = false
            UIApplication.shared.keyWindow?.addSubview(bannerView)
            
            UserDefaults.Main.set(true, forKey: .isShowBannerAds)
            UserDefaults.standard.synchronize()
        }
    }
//MARK: - Change app orientation
    @objc func changeAppOrientation(notification: Notification) {
        
        var isPortrait = true
        
        switch UIDevice.current.orientation {
        case .portrait:
            
            break
        case .portraitUpsideDown:
            
            break
        case .landscapeLeft:
            isPortrait = false;
            break
        case .landscapeRight:
            isPortrait = false;
            break
        default:
            
            break
        }
        
        //Show Banner View
        self.showBannerView(isPortrait: isPortrait)
        
    }
//MARK: - Hide - Show Banner View
    func showBannerView(isPortrait:Bool=true) {
        
        print("showBannerView")
        isBannerViewDisplay = true
        if self.bannerView != nil {
            if isInitializeBannerView == false {
                
                print("First initialize Banner View")
            } else {
                
                print("isBannerViewCreate : true")
                UserDefaults.Main.set(true, forKey: .isShowBannerAds)
                UserDefaults.standard.synchronize()
                
                NotificationCenter.default.post(name: Notification.Name("bannerAdsReceived"), object: nil)
                
                self.bannerView.isHidden = false
                let screenHeight = BannerViewSize.screenHeight > BannerViewSize.screenWidth ? BannerViewSize.screenHeight : BannerViewSize.screenWidth
                let screenWidth = BannerViewSize.screenHeight > BannerViewSize.screenWidth ? BannerViewSize.screenWidth : BannerViewSize.screenHeight
                
                if isPortrait == true {
                
                    let notchHeight = hasTopNotch == true ? CGFloat(34):CGFloat(0)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.bannerView.frame = CGRect(x:0 ,y:screenHeight - BannerViewSize.height - notchHeight  ,width:screenWidth ,height:BannerViewSize.height)
                    })
                    
                } else {
                    let notchHeight = CGFloat(0)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.bannerView.frame = CGRect(x:0 ,y:screenWidth - BannerViewSize.height - notchHeight  ,width:screenHeight ,height:BannerViewSize.height)
                    })
                }
            }
        }
    }
    func hideBannerView() {
        
        print("hideBannerView")
        isBannerViewDisplay = false
        if self.bannerView != nil {
            UserDefaults.Main.set(false, forKey: .isShowBannerAds)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name("bannerAdsReceived"), object: nil)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bannerView.frame = CGRect(x:0 ,y:BannerViewSize.screenHeight ,width:BannerViewSize.screenWidth ,height:BannerViewSize.height)
            })
        }
    }
    @objc private func showBanner() {

        print("showBanner")
        if self.bannerView != nil && isBannerViewDisplay == true {
            self.bannerView.isHidden = false
            
            UserDefaults.Main.set(true, forKey: .isShowBannerAds)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name("bannerAdsReceived"), object: nil)
        }
    }
    private func hideBanner() {
        
        print("hideBanner")
        if self.bannerView != nil {
            self.bannerView.isHidden = true
            
            UserDefaults.Main.set(false, forKey: .isShowBannerAds)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name("bannerAdsReceived"), object: nil)
        }
    }
//MARK: - GADBannerView Delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        if self.bannerView != nil {
            self.bannerView.isUserInteractionEnabled = true
        }
        
        UserDefaults.Main.set(true, forKey: .isBannerAdsReceived)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name("bannerAdsReceived"), object: nil)
        
        print("adViewDidReceiveAd")
    }
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewDidDismissScreen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillDismissScreen")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillPresentScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
        print("adViewWillLeaveApplication")
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("adView")
    }
//MARK: - Create Interstitial Ads
    func initializeInterstitial(isLiveUnitID:Bool) {
        self.isInitializeInterstitial = true
        self.isInterstitialLiveID = isLiveUnitID
        self.createInterstitial()
    }
    private func createInterstitial() {
        
        if self.isInterstitialLiveID == false {
            interstitialAds = GADInterstitial(adUnitID: GoogleAdsUnitID.Test.strInterstitialAdsID)
        } else {
            interstitialAds = GADInterstitial(adUnitID: GoogleAdsUnitID.Live.strInterstitialAdsID)
        }
        
        interstitialAds.delegate = self
        interstitialAds.load(GADRequest())
    }
//MARK: - Show Interstitial Ads
    func showInterstitial() {
        
        if isInitializeInterstitial == false {
            
            print("First initialize Interstitial")
        } else {
            
            if interstitialAds.isReady {
                interstitialAds.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
                
            } else {
                print("Interstitial not ready")
                self.createInterstitial()
            }
        }
    }
//MARK: - GADInterstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
        print("interstitialDidReceiveAd")
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialDidDismissScreen")
        self.createInterstitial()
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillDismissScreen")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showBanner), object: nil)
        self.perform(#selector(showBanner), with: nil, afterDelay: 0.1)
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillPresentScreen")
        self.hideBanner()
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        
        print("interstitialWillLeaveApplication")
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        
        print("interstitialDidFail")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("interstitial")
    }
}
