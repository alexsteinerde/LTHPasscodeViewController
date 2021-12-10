//
//  LTHPasscodeViewControllerDelegate.swift
//  LTHPasscodeViewController Demo
//
//  Created by Jason Rodriguez on 12/10/21.
//  Copyright © 2021 Roland Leth. All rights reserved.
//

import Foundation

@objc protocol LTHPasscodeViewControllerDelegate: NSObjectProtocol {

    /**
     @brief Called right before the passcode view controller will be dismissed or popped.
     */
    @objc optional func passcodeViewControllerWillClose()
    /**
     @brief Called when the max number of failed attempts has been reached.
     */
    @objc optional func maxNumberOfFailedAttemptsReached()
    /**
     @brief Called when the passcode was entered successfully.
     */
    @objc optional func passcodeWasEnteredSuccessfully()
    /**
     @brief Called when the TouchID/FaceID fails or is cancelled.
     */
    @objc optional func biometricsAuthenticationFailed()
    /**
     @brief Called when the passcode was enabled.
     */
    @objc optional func passcodeWasEnabled()
    /**
     @brief Called when the logout button was pressed.
     */
    @objc optional func logoutButtonWasPressed()
    /**
     @brief      Handle here the retrieval of the duration that needs to pass while app is in background for the lock to be displayed.
     @details Called when @c +timerDuration is called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @return The duration.
     */
    @objc optional func timerDuration() -> TimeInterval
    /**
     @brief             Handle here the saving of the duration that needs to pass while the app is in background for the lock to be displayed.
     @details        Called when @c +saveTimerDuration: is called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @param duration The duration.
     */
    @objc optional func saveTimerDuration(_ duration: TimeInterval)
    /**
     @brief   Handle here the retrieval of the time at which the timer started.
     @details Called when @c +timerStartTime is called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @return The time at which the timer started.
     */
    @objc optional func timerStartTime() -> TimeInterval
    /**
     @brief    Handle here the saving of the current time.
     @details  Called when @c +saveTimerStartTime is called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     */
    @objc optional func saveTimerStartTime()
    /**
     @brief      Handle here the check if the timer has ended and the lock has to be displayed.
     @details    Called when @c +didPasscodeTimerEnd is called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @return @c YES if the timer ended and the lock has to be displayed.
     */
    @objc optional func didPasscodeTimerEnd() -> Bool
    /**
     @brief   Handle here the passcode deletion.
     @details Called when @c +deletePasscode or @c +deletePasscodeAndClose are called and @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     */
    @objc optional func deletePasscode()
    /**
     @brief   Handle here the saving of the passcode.
     @details Called if @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @param passcode The passcode.
     */
    @objc optional func savePasscode(_ passcode: String)
    /**
     @brief   Retrieve here the saved passcode.
     @details Called if @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @return The passcode.
     */
    @objc optional func passcode() -> String!
    /**
     @brief   Handle here the saving of the preference for allowing the use of Biometrics.
     @details Called if @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @param allowUnlockWithBiometrics The boolean for the preference for allowing the use of Biometrics.
     */
    @objc optional func saveAllowUnlockWithBiometrics(_ allowUnlockWithBiometrics: Bool)
    /**
     @brief   Retrieve here the saved preference for allowing the use of Biometrics.
     @details Called if @c +useKeychain:NO was used, but falls back to the Keychain anyway if not implemented.
     @return allowUnlockWithBiometrics boolean.
     */
    @objc optional func allowUnlockWithBiometrics() -> Bool
}



