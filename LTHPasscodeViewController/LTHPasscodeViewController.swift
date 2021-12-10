//
//  LTHPasscodeViewController.swift
//  LTHPasscodeViewController Demo
//
//  Created by Jason Rodriguez on 12/10/21.
//  Copyright © 2021 Roland Leth. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class LTHPasscodeViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate let LTHiPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
#if LTH_IS_APP_EXTENSION
    fileprivate let LTHMainWindow = UIApplication.shared.keyWindow
#else
    fileprivate let LTHMainWindow = UIApplication.shared.windows.first
#endif
    
    fileprivate func LTHLocalizedString(_ key: String) -> String? {
        let currentBundle = Bundle(for: LTHPasscodeViewController.self)
        let lthBundle = Bundle(path: currentBundle.path(forResource: "LTHPasscodeViewController", ofType: "bundle") ?? "")
        lthBundle?.localizedString(forKey: key, value: "", table: localizationTableName)
    }
    
    fileprivate func LTHPasscodeViewControllerStrings(_ key: String) -> String? {
        LTHLocalizedString(key)?.isEmpty ?? true
        ? Bundle(path: Bundle.module.path(forResource: "LTHPasscodeViewController", ofType: "bundle") ?? "")?.localizedString(forKey: "Unlock using Touch ID", value: "", table: localizationTableName)
        : LTHLocalizedString(key)
    }
    
    /**
     @brief   The delegate.
     */
    weak var delegate: LTHPasscodeViewControllerDelegate?
    /**
     @brief        The number of digits for the simple passcode. Default is @c 4, or the length of the passcode, if one exists.
     
     @b Attention: If you increase the number of digits and they do not fit on screen anymore, please decrease the @c horizontalGap accordingly.
     
     @b Warning:   If a passcode is present, changing this will not work, since it would not allow the user to enter his passcode anymore. Please disable the passcode first.
     */
    var digitsCount = 0
    /**
     @brief      The gap between the passcode digits. Default is @c 40 for iPhone, @c 60 for iPad.
     */
    var horizontalGap: CGFloat = 0.0
    /**
     @brief The gap between the top label and the passcode digits/field.
     */
    var verticalGap: CGFloat = 0.0
    /**
     @brief The offset between the top label and middle position.
     */
    var verticalOffset: CGFloat = 0.0
    /**
     @brief The gap between the passcode digits and the failed label.
     */
    var failedAttemptLabelGap: CGFloat = 0.0
    /**
     @brief The height for the complex passcode overlay.
     */
    var passcodeOverlayHeight: CGFloat = 0.0
    /**
     @brief The font size for the top label.
     */
    var labelFontSize: CGFloat = 0.0
    /**
     @brief The font size for the passcode digits.
     */
    var passcodeFontSize: CGFloat = 0.0
    /**
     @brief The font for the top label.
     */
    var labelFont: UIFont?
    /**
     @brief The font for the passcode digits.
     */
    var passcodeFont: UIFont?
    /**
     @brief The background color for the top label.
     */
    var enterPasscodeLabelBackgroundColor: UIColor?
    /**
     @brief The background color for the view.
     */
    var backgroundColor: UIColor?
    /**
     @brief The background image for the coverview.
     */
    var backgroundImage: UIImage?
    /**
     @brief The background color for the cover view that appears on top of the app, visible in the multitasking.
     */
    var coverViewBackgroundColor: UIColor?
    /**
     @brief The background color for the passcode digits.
     */
    var passcodeBackgroundColor: UIColor?
    /**
     @brief The background color for the failed attempt label.
     */
    var failedAttemptLabelBackgroundColor: UIColor?
    /**
     @brief The text color for the top label.
     */
    var labelTextColor: UIColor?
    /**
     @brief The text color for the passcode digits.
     */
    var passcodeTextColor: UIColor?
    /**
     @brief The text color for the failed attempt label.
     */
    var failedAttemptLabelTextColor: UIColor?
    /**
     @brief The tint color to apply to the navigation items and bar button items.
     */
    var navigationBarTintColor: UIColor?
    /**
     @brief The tint color to apply to the navigation bar background.
     */
    var navigationTintColor: UIColor?
    /**
     @brief The color for te navigation bar's title.
     */
    var navigationTitleColor: UIColor?
    /**
     @brief The string to be used as username for the passcode in the Keychain.
     */
    var keychainPasscodeUsername: String?
    /**
     @brief The string to be used as username for the timer start time in the Keychain.
     */
    var keychainTimerStartUsername: String?
    /**
     @brief The string to be used as username for the timer duration in the Keychain.
     */
    var keychainTimerDurationUsername: String?
    /**
     @brief The string to be used as username for the "isSimple" in the Keychain.
     */
    var keychainPasscodeIsSimpleUsername: String?
    /**
     @brief The string to be used as service name for all the Keychain entries.
     */
    var keychainServiceName: String?
    /**
     @brief The string to be used as username for allow Biometrics unlock in the Keychain.
     */
    var keychainAllowUnlockWithBiometrics: String?
    /**
     @brief The character for the passcode digit.
     */
    var passcodeCharacter: String?
    /**
     @brief The table name for NSLocalizedStringFromTable.
     */
    var localizationTableName: String?
    /**
     @brief The tag for the cover view.
     */
    var coverViewTag = 0
    /**
     @brief The string displayed when entering your old passcode (while changing).
     */
    var enterOldPasscodeString: String?
    /**
     @brief The string displayed when entering your passcode.
     */
    var enterPasscodeString: String?
    /**
     @brief The string used to explain the reason of setting passcode.
     @details The given string is oprional and is displayed below passcode field.
     */
    var enterPasscodeInfoString: String?
    /**
     @brief A Boolean value that indicates whether the @c enterPasscodeInfoString is displayed (@c YES) or not (@c NO). Default is @c YES.
     */
    var displayAdditionalInfoDuringSettingPasscode = false
    /**
     @brief The string displayed when entering your new passcode (while changing).
     */
    var enterNewPasscodeString: String?
    /**
     @brief The string displayed when enabling your passcode.
     */
    var enablePasscodeString: String?
    /**
     @brief The string displayed when changing your passcode.
     */
    var changePasscodeString: String?
    /**
     @brief The string displayed when disabling your passcode.
     */
    var turnOffPasscodeString: String?
    /**
     @brief The string displayed when reentering your passcode.
     */
    var reenterPasscodeString: String?
    /**
     @brief The string displayed when reentering your new passcode (while changing).
     */
    var reenterNewPasscodeString: String?
    /**
     @brief The string displayed while user unlocks with Biometrics.
     @details Do not forget to test what kind of Biometrics the device is using, and display the correct string. (Touch ID vs Face ID, for example)
     */
    var biometricsDetailsString: String?
    /**
     @brief The duration of the lock animation.
     */
    var lockAnimationDuration: CGFloat = 0.0
    /**
     @brief The duration of the slide animation.
     */
    var slideAnimationDuration: CGFloat = 0.0
    /**
     @brief The maximum number of failed attempts allowed.
     */
    var maxNumberOfAllowedFailedAttempts = 0
    /**
     @brief The navigation bar, if one was used.
     */
    var navBar: UINavigationBar?
    /**
     @brief A Boolean value that indicates whether the navigation bar is translucent (@c YES) or not (@c NO).
     */
    var navigationBarTranslucent = false
    /**
     @brief A Boolean value that indicates whether the back bar button is hidden (@c YES) or not (@c NO). Default is @c YES.
     */
    var hidesBackButton = false
    
    /**
     @brief A Boolean value that indicates whether the right bar button is hidden (@c YES) or not (@c NO). Default is @c YES.
     */
    var hidesCancelButton = false
    
    /**
     @brief A Boolean value that indicates whether Biometrics can be used (@c YES) or not (@c NO). Default is @c YES.
     */
    var allowUnlockWithBiometrics = false
    
    /**
     @brief A Boolean value that indicates whether the lockscreen is currently on screen or not.
     */
    private(set) var isCurrentlyOnScreen = false
    
    
    private var coverView: UIView?
    private var animatingView: UIView?
    private var complexPasscodeOverlayView: UIView?
    private var simplePasscodeView: UIView?
    private var backgroundImageView: UIImageView?
    
    private var passcodeTextField: UITextField?
    private var enterPasscodeInfoLabel: UILabel?
    
    private var digitTextFieldsArray: [UITextField]?
    
    private var failedAttemptLabel: UILabel?
    private var enterPasscodeLabel: UILabel?
    private var OKButton: UIButton?
    
    private var tempPasscode: String?
    private var failedAttempts = 0
    
    private var modifierForBottomVerticalGap: CGFloat = 0.0
    private var fontSizeModifier: CGFloat = 0.0
    
    private var newPasscodeEqualsOldPasscode = false
    private var passcodeAlreadyExists = false
    private var usesKeychain = false
    private var displayedAsModal = false
    private var displayedAsLockScreen = false
    private var isUsingNavBar = false
    private var isSimple = false // YES by default
    private var isUserConfirmingPasscode = false
    private var isUserBeingAskedForNewPasscode = false
    private var isUserTurningPasscodeOff = false
    private var isUserChangingPasscode = false
    private var isUserEnablingPasscode = false
    private var isUserSwitchingBetweenPasscodeModes = false // simple/complex
    private var timerStartInSeconds = false
    private var isUsingBiometrics = false
    private var useFallbackPasscode = false
    private var isAppNotificationsObserved = false
    private var biometricsContext: LAContext?
    
    let LTHMinPasscodeDigits = 4
    let LTHMaxPasscodeDigits = 10
    
    // MARK: - Public, class methods
    
    class func doesPasscodeExist() -> Bool {
        return self.sharedUser()._doesPasscodeExist()
    }
    
    class func timerDuration() -> TimeInterval {
        return self.sharedUser()._timerDuration()
    }
    
    class func saveTimerDuration(_ duration: TimeInterval) {
        self.sharedUser()._saveTimerDuration(duration)
    }
    
    class func timerStartTime() -> TimeInterval {
        return self.sharedUser()._timerStartTime()
    }
    
    class func saveTimerStartTime() {
        self.sharedUser()._saveTimerStartTime()
    }
    
    class func didPasscodeTimerEnd() -> Bool {
        return self.sharedUser()._didPasscodeTimerEnd()
    }
    
    class func deletePasscodeAndClose() {
        self.deletePasscode()
        self.close()
    }
    
    class func close() {
        self.sharedUser()._close()
    }
    
    class func deletePasscode() {
        self.sharedUser()._deletePasscode()
    }
    
    class func useKeychain(_ useKeychain: Bool) {
        self.sharedUser()._useKeychain(useKeychain)
    }
    
    // MARK: - Private methods
    
    private func _close() {
        if displayedAsLockScreen {
            _dismissMe()
        } else {
            _cancelAndDismissMe()
        }
    }
    
    private func _useKeychain(_ useKeychain: Bool) {
        usesKeychain = useKeychain
    }
    
    private func _doesPasscodeExist() -> Bool {
        do {
            if let password = try LTHKeychainUtils.getPasswordForUsername(keychainPasscodeIsSimpleUsername, andServiceName: keychainServiceName) {
                isSimple = true
            } else {
                isSimple = true
            }
        } catch {
            return false
        }
        return _passcode().length != 0
    }
    
    func _timerDuration() -> TimeInterval {
        if !usesKeychain && delegate?.responds(to: Selector("timerDuration")) {
            return delegate?.timerDuration()
        }
        
        var keychainValue: String? = nil
        do {
            keychainValue = try LTHKeychainUtils.getPasswordForUsername(
                keychainTimerDurationUsername,
                andServiceName: keychainServiceName)
        } catch {
            return -1
        }
        return TimeInterval(Double(keychainValue ?? "") ?? 0.0)
    }
    
    func _saveTimerDuration(_ duration: TimeInterval) {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("saveTimerDuration:")) {
            delegate.saveTimerDuration(duration)
            
            return
        }
        
        do {
            try LTHKeychainUtils.storeUsername(
                keychainTimerDurationUsername,
                andPassword: String(format: "%.6f", duration),
                forServiceName: keychainServiceName,
                updateExisting: true)
        } catch {
        }
    }
    
    func _timerStartTime() -> TimeInterval {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("timerStartTime")) {
            return delegate.timerStartTime()
        }
        
        var keychainValue: String? = nil
        do {
            keychainValue = try LTHKeychainUtils.getPasswordForUsername(
                keychainTimerStartUsername,
                andServiceName: keychainServiceName)
        } catch {
            return -1
        }
        return TimeInterval(Double(keychainValue ?? "") ?? 0.0)
    }
    
    func _saveTimerStartTime() {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("saveTimerStartTime")) {
            delegate.saveTimerStartTime()
            return
        }
        
        do {
            try LTHKeychainUtils.storeUsername(
                keychainTimerStartUsername,
                andPassword: String(format: "%.6f", Date.timeIntervalSinceReferenceDate),
                forServiceName: keychainServiceName,
                updateExisting: true)
        } catch {
        }
    }
    
    func _didPasscodeTimerEnd() -> Bool {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("didPasscodeTimerEnd")) {
            return delegate.didPasscodeTimerEnd()
        }
        
        let now = Date.timeIntervalSinceReferenceDate
        // startTime wasn't saved yet (first app use and it crashed, phone force
        // closed, etc) if it returns -1.
        return now - _timerStartTime() >= _timerDuration() || _timerStartTime() == -1 || now <= _timerStartTime()
        // If the date was set in the past, this would return false.
        // It won't register as false, even right as it is being enabled,
        // because the saving alone takes 0.002+ seconds on a MBP 2.6GHz i7.
    }
    
    func _deletePasscode() {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("deletePasscode")) {
            delegate.deletePasscode()
            
            return
        }
        
        do {
            try LTHKeychainUtils.deleteItem(
                forUsername: keychainPasscodeUsername,
                andServiceName: keychainServiceName)
        } catch {
        }
    }
    
    func _savePasscode(_ passcode: String?) {
        if let delegate = delegate, !passcodeAlreadyExists && delegate.responds(to: Selector("passcodeWasEnabled")) {
            delegate.passcodeWasEnabled()
        }
        
        passcodeAlreadyExists = true
        
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("savePasscode:")) {
            delegate.savePasscode(passcode)
            
            return
        }
        
        do {
            try LTHKeychainUtils.storeUsername(
                keychainPasscodeUsername,
                andPassword: passcode,
                forServiceName: keychainServiceName,
                updateExisting: true)
        } catch {
        }
        
        do {
            try LTHKeychainUtils.storeUsername(keychainPasscodeIsSimpleUsername, andPassword: "\(isSimple() ? "YES" : "NO")", forServiceName: keychainServiceName, updateExisting: true)
        } catch {
        }
        
    }
    
    func _passcode() -> String? {
        if let delegate = delegate, !usesKeychain && delegate.responds(to: Selector("passcode")) {
            return delegate.passcode()
        }
        
        return try? LTHKeychainUtils.getPasswordForUsername(keychainPasscodeUsername, andServiceName: keychainServiceName)
    }
    
    func resetPasscode() {
        if _doesPasscodeExist() {
            let passcode = _passcode()
            _deletePasscode()
            _savePasscode(passcode)
        }
    }
    
    func _handleBiometricsFailureAndDisableIt(_ disableBiometrics: Bool) {
        DispatchQueue.main.async(execute: { [self] in
            if disableBiometrics {
                isUsingBiometrics = false
                allowUnlockWithBiometrics = false
                useFallbackPasscode = true
                animatingView.hidden = false
                
                let usingNavBar = isUsingNavBar
                let logoutTitle = usingNavBar ? navBar.items.first?.leftBarButtonItem?.title : ""
                
                _resetUI()
                
                if usingNavBar {
                    isUsingNavBar = usingNavBar
                    _setupNavBar(withLogoutTitle: logoutTitle)
                }
            }
        })
        
        biometricsContext = nil
    }
    
    func _setupFingerPrint() {
        if !biometricsContext && allowUnlockWithBiometrics && !useFallbackPasscode {
            biometricsContext = LAContext()
            
            var error: Error? = nil
            if biometricsContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if error != nil {
                    return
                }
                if #available(iOS 11.0, *) {
                    if biometricsContext.biometryType == .faceID {
                        biometricsDetailsString = "Unlock using Face ID"
                    }
                }
                
                isUsingBiometrics = true
                passcodeTextField.resignFirstResponder()
                animatingView.hidden = true
                
                // Authenticate User
                if biometricsContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    biometricsContext.evaluatePolicy(
                        .deviceOwnerAuthenticationWithBiometrics,
                        localizedReason: LTHPasscodeViewControllerStrings(biometricsDetailsString),
                        reply: { [self] success, error in
                            if error != nil || !success {
                                _handleBiometricsFailureAndDisableIt(false)
                                if delegate.responds(to: Selector("biometricsAuthenticationFailed")) {
                                    delegate.perform(Selector("biometricsAuthenticationFailed"))
                                }
                                return
                            }
                            
                            DispatchQueue.main.async(execute: { [self] in
                                _dismissMe()
                                
                                if delegate.responds(to: Selector("passcodeWasEnteredSuccessfully")) {
                                    delegate.perform(Selector("passcodeWasEnteredSuccessfully"))
                                }
                            })
                            
                            biometricsContext = nil
                        })
                }
            }
        } else {
            _handleBiometricsFailureAndDisableIt(true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    func _resetUIForReEnteringNewPasscode() {
        _resetTextFields()
        passcodeTextField?.text = ""
        // If there's no passcode saved in Keychain,
        // the user is adding one for the first time, otherwise he's changing his passcode.
        var savedPasscode: String? = nil
        do {
            savedPasscode = try LTHKeychainUtils.getPasswordForUsername(
                keychainPasscodeUsername,
                andServiceName: keychainServiceName)
        } catch {
        }
        enterPasscodeLabel.text = savedPasscode?.isEmpty
        ? LTHPasscodeViewControllerStrings(enterPasscodeString)
        : LTHPasscodeViewControllerStrings(enterNewPasscodeString)
        failedAttemptLabel?.isHidden = false
        failedAttemptLabel.text = newPasscodeEqualsOldPasscode
        ? LTHPasscodeViewControllerStrings("Cannot reuse the same passcode")
        : LTHPasscodeViewControllerStrings("Passcodes did not match. Try again.")
        newPasscodeEqualsOldPasscode = false
        failedAttemptLabel?.backgroundColor = UIColor.clear
        failedAttemptLabel?.layer.borderWidth = 0
        failedAttemptLabel?.layer.borderColor = UIColor.clear.cgColor
        failedAttemptLabel?.textColor = labelTextColor
    }
    
    func setIsSimple(_ isSimple: Bool, in viewController: UIViewController?, asModal isModal: Bool) {
        if !isUserSwitchingBetweenPasscodeModes && !isUserBeingAskedForNewPasscode && _doesPasscodeExist() {
            // User trying to change passcode type while having passcode already
            isUserSwitchingBetweenPasscodeModes = true
            // Display modified change passcode flow starting with input once passcode
            // of current type and then 2 times new one of another type
            showForChangingPasscode(in: viewController, asModal: isModal)
        } else {
            isUserSwitchingBetweenPasscodeModes = false
            self.isSimple = isSimple
            view.setNeedsUpdateConstraints()
        }
    }
    
    func isSimple() -> Bool {
        // Is in process of changing, but not finished ->
        // we need to display UI accordingly
        return (isUserSwitchingBetweenPasscodeModes && (isUserBeingAskedForNewPasscode || isUserConfirmingPasscode)) == !isSimple
    }
    
    // MARK: - Notification Observers
    
    func _applicationDidEnterBackground() {
        if _doesPasscodeExist() {
            if let passcodeTextField = passcodeTextField, passcodeTextField.isFirstResponder {
                useFallbackPasscode = false
                passcodeTextField.resignFirstResponder()
            }
            
            if isCurrentlyOnScreen && !displayedAsModal {
                return
            }
            
            coverView?.isHidden = false
            if !LTHMainWindow.view(withTag: coverViewTag) {
                LTHMainWindow.addSubview(coverView)
            }
        }
    }
    
    func _applicationDidBecomeActive() {
        // If we are not being displayed as lockscreen, it means the biometrics alert
        // just closed - it also calls UIApplicationDidBecomeActiveNotification
        // and if we open for changing / turning off really fast, it will call this
        // after viewWillAppear, and it will hide the UI.
        if isUsingBiometrics && !useFallbackPasscode && displayedAsLockScreen {
            animatingView?.isHidden = true
            passcodeTextField?.resignFirstResponder()
        }
        coverView?.isHidden = true
    }
    
    func _applicationWillEnterForeground() {
        if _doesPasscodeExist() && _didPasscodeTimerEnd() {
            useFallbackPasscode = false
            
            if !displayedAsModal && !displayedAsLockScreen && isCurrentlyOnScreen {
                passcodeTextField?.resignFirstResponder()
                navigationController?.popViewController(animated: false)
                // This is like this because it screws up the navigation stack otherwise
                perform(Selector("showLockscreenWithoutAnimation"), with: nil, afterDelay: 0.0)
            } else {
                showLockScreen(withAnimation: false, withLogout: false, andLogoutTitle: nil)
            }
        }
    }
    
    func _applicationWillResignActive() {
        if _doesPasscodeExist() && !(isCurrentlyOnScreen() && displayedAsLockScreen()) {
            useFallbackPasscode = false
            _saveTimerStartTime()
        }
    }
    
    // MARK: - Init
    
    fileprivate static let _sharedUser: LTHPasscodeViewController = LTHPasscodeViewController()
    
    static func sharedUser() -> LTHPasscodeViewController {
        Self._sharedUser
    }
    
    init() {
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _commonInit()
    }
    
    func _commonInit() {
        _loadDefaults()
    }
    
    func _loadDefaults() {
        _loadMiscDefaults()
        _loadStringDefaults()
        _loadGapDefaults()
        _loadFontDefaults()
        _loadColorDefaults()
        _loadKeychainDefaults()
    }
    
    func _loadMiscDefaults() {
        digitsCount = LTHMinPasscodeDigits
        digitTextFieldsArray = []
        coverViewTag = 994499
        lockAnimationDuration = 0.25
        slideAnimationDuration = 0.15
        maxNumberOfAllowedFailedAttempts = 0
        usesKeychain = true
        isSimple = true
        displayedAsModal = true
        hidesBackButton = true
        hidesCancelButton = true
        passcodeAlreadyExists = true
        newPasscodeEqualsOldPasscode = false
        allowUnlockWithBiometrics = _allowUnlockWithBiometrics()
        passcodeCharacter = "\u{2014}" // A longer "-";
        localizationTableName = "LTHPasscodeViewController"
        displayAdditionalInfoDuringSettingPasscode = false
    }
    
    func _loadStringDefaults() {
        enterOldPasscodeString = "Enter your old passcode"
        enterPasscodeString = "Enter your passcode"
        enterPasscodeInfoString = "Passcode info"
        enablePasscodeString = "Enable Passcode"
        changePasscodeString = "Change Passcode"
        turnOffPasscodeString = "Turn Off Passcode"
        reenterPasscodeString = "Re-enter your passcode"
        reenterNewPasscodeString = "Re-enter your new passcode"
        enterNewPasscodeString = "Enter your new passcode"
        biometricsDetailsString = "Unlock using Touch ID"
    }
    
    func _loadGapDefaults() {
        fontSizeModifier = LTHiPad ? 1.5 : 1
        horizontalGap = 40 * fontSizeModifier
        verticalGap = LTHiPad ? 60.0 : 25.0
        modifierForBottomVerticalGap = LTHiPad ? 2.6 : 3.0
        failedAttemptLabelGap = verticalGap * modifierForBottomVerticalGap - 2.0
        passcodeOverlayHeight = LTHiPad ? 96.0 : 40.0
    }
    
    func _loadFontDefaults() {
        labelFontSize = 15.0
        passcodeFontSize = 33.0
        labelFont = UIFont(
            name: "AvenirNext-Regular",
            size: labelFontSize * fontSizeModifier)
        passcodeFont = UIFont(
            name: "AvenirNext-Regular",
            size: passcodeFontSize * fontSizeModifier)
    }
    
    func _loadColorDefaults() {
        // Backgrounds
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 1.0, alpha: 1.00)
        passcodeBackgroundColor = UIColor.clear
        coverViewBackgroundColor = UIColor(red: 0.97, green: 0.97, blue: 1.0, alpha: 1.00)
        failedAttemptLabelBackgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.2, alpha: 1.000)
        enterPasscodeLabelBackgroundColor = UIColor.clear
        
        // Text
        labelTextColor = UIColor(white: 0.31, alpha: 1.0)
        passcodeTextColor = UIColor(white: 0.31, alpha: 1.0)
        failedAttemptLabelTextColor = UIColor.white
    }
    
    func _loadKeychainDefaults() {
        keychainPasscodeUsername = "demoPasscode"
        keychainTimerStartUsername = "demoPasscodeTimerStart"
        keychainServiceName = "demoServiceName"
        keychainTimerDurationUsername = "passcodeTimerDuration"
        keychainPasscodeIsSimpleUsername = "passcodeIsSimple"
        keychainAllowUnlockWithBiometrics = "allowUnlockWithTouchID"
    }
    
    func _addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationDidEnterBackground"),
            name: UIApplicationDelegate.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationWillResignActive"),
            name: UIApplicationDelegate.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationDidBecomeActive"),
            name: UIApplicationDelegate.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationWillEnterForeground"),
            name: UIApplicationDelegate.willEnterForegroundNotification,
            object: nil)
    }
    
    // MARK: - Handling rotation
    
    // Internal method for fetching the current orientation
    class func currentOrientation() -> UIInterfaceOrientation {
        // statusBarOrientation is deprecated in iOS 13 and windowScene isn't available before iOS 13
        if #available(iOS 13.0, *) {
            return LTHMainWindow.windowScene.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // I'll be honest and mention I have no idea why this line of code below works.
        // Without it, if you present the passcode view as lockscreen (directly on the window)
        // and then inside of a modal, the orientation will be wrong.
        
        // If you could explain why, I'd be more than grateful :)
        return .portrait
    }
    
    // And to his AGWindowView: https://github.com/hfossli/AGWindowView
    // Without the 'desiredOrientation' method, using showLockscreen in one orientation,
    // then presenting it inside a modal in another orientation would display
    // the view in the first orientation.
    func desiredOrientation() -> UIInterfaceOrientation {
        let statusBarOrientation = LTHPasscodeViewController.currentOrientation()
        let statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation)
        
        if (supportedInterfaceOrientations & statusBarOrientationAsMask) {
            return statusBarOrientation
        } else {
            if supportedInterfaceOrientations.rawValue & UIInterfaceOrientationMask.portrait.rawValue != 0 {
                return UIInterfaceOrientation.portrait
            } else if supportedInterfaceOrientations.rawValue & UIInterfaceOrientationMask.landscapeLeft.rawValue != 0 {
                return UIInterfaceOrientation.landscapeLeft
            } else if supportedInterfaceOrientations.rawValue & UIInterfaceOrientationMask.landscapeRight.rawValue != 0 {
                return UIInterfaceOrientation.landscapeRight
            } else {
                return UIInterfaceOrientation.portraitUpsideDown
            }
        }
    }
    
    func rotateAccordingToStatusBarOrientationAndSupportedOrientations() {
        let orientation = desiredOrientation()
        let angle = UIInterfaceOrientationAngleOfOrientation(orientation)
        let transform = CGAffineTransform(rotationAngle: angle)
        let frame = view.superview?.frame
        
        if !(view.transform == transform) {
            view.transform = transform
        }
        
        if let frame = frame, !view.frame.equalTo(frame) {
            view.frame = frame
        }
    }
    
    func disablePasscodeWhenApplicationEntersBackground() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplicationDelegate.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplicationDelegate.willEnterForegroundNotification,
            object: nil)
    }
    
    func enablePasscodeWhenApplicationEntersBackground() {
        // To avoid double registering.
        disablePasscodeWhenApplicationEntersBackground()
        
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationDidEnterBackground"),
            name: UIApplicationDelegate.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: Selector("_applicationWillEnterForeground"),
            name: UIApplicationDelegate.willEnterForegroundNotification,
            object: nil)
    }
    
    class func getStatusBarHeight() -> CGFloat {
        let orientation = LTHPasscodeViewController.currentOrientation()
        
        // statusBarFrame is deprecated in iOS 13 and windowScene isn't available before iOS 13
        if #available(iOS 13.0, *) {
            if orientation.isLandscape {
                return LTHMainWindow.windowScene.statusBarManager?.statusBarFrame.size.width ?? 0.0
            } else {
                return LTHMainWindow.windowScene.statusBarManager?.statusBarFrame.size.height ?? 0.0
            }
        } else {
            if orientation.isLandscape {
                return UIApplication.shared.statusBarFrame.size.width
            } else {
                return UIApplication.shared.statusBarFrame.size.height
            }
        }
    }
    
    func UIInterfaceOrientationAngleOfOrientation(_ orientation: UIInterfaceOrientation) -> CGFloat {
        var angle: CGFloat
        
        switch orientation {
        case .portraitUpsideDown:
            angle = .pi
        case .landscapeLeft:
            angle = -(.pi / 2)
        case .landscapeRight:
            angle = .pi / 2
        default:
            angle = 0.0
        }
        
        return angle
    }
    
    func UIInterfaceOrientationMaskFromOrientation(_ orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask {
        return (UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue))
    }
}
