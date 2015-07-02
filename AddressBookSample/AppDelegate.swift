//
//  AppDelegate.swift
//  AddressBookSample
//
//  Created by 加藤直人 on 7/2/15.
//  Copyright (c) 2015 加藤直人. All rights reserved.
//

import UIKit
import AddressBook

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /** 
    * ABAddressBookRefのインスタンス
    * これを媒介にしてアドレス帳にアクセス
    * lazy指定して呼び出されたときにインスタンス化するようにする
    */
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
    }()

    /** 
    * 起動時に呼び出される
    * switchの条件文 ABAddressBookGetAuthorizationStatus() でユーザーに連絡帳へのアクセス許可申請
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        switch ABAddressBookGetAuthorizationStatus() {
        case .Authorized:
            println("Already authorized")
            readFromAddressBook(addressBook)
        case .Denied:
            println("You are denied access to address book")
        case .NotDetermined:
            println("Not determined")
            ABAddressBookRequestAccessWithCompletion(addressBook) {
                [weak self] (granted: Bool, error: CFError!) in
                
                if granted {
                    let strongSelf = self!
                    println("Access is granted!")
                    strongSelf.readFromAddressBook(strongSelf.addressBook)
                } else {
                    println("Access is not granted...")
                }
                
            }
        case .Restricted:
            println("Access is restricted")
        default:
            println("Unhandled")
            
        }
        
        
        return true
    }
    
    /** 
    * アドレス帳から名前と電話番号一覧を呼び出し
    * @param addressBook
    */
    func readFromAddressBook(addressBook: ABAddressBookRef) {
        //すべての連絡先取得
        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        
        //forループで情報表示
        for person: ABRecordRef in allPeople {
            //名前取得
            if let name = ABRecordCopyCompositeName(person) {
                println(name.takeRetainedValue())
                
                //電話番号取得（電話番号は複数持つ可能性がある）
                var tels: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
                //電話番号の数
                var num = ABMultiValueGetCount(tels)
                //forループですべて表示
                for i in 0..<num {
                    if let tel = ABMultiValueCopyValueAtIndex(tels, i) {
                        println("  \(tel.takeRetainedValue())")
                    }
                }
            }
        }
    }
}

