//
//  ViewController.swift
//  TelrSDKDemo
//
//  Created by Onkar Borse on 17/04/19.
//  Copyright © 2019 Girish. All rights reserved.
//

import UIKit
import TelrSDK

class ViewController: UIViewController {
    
   
    
//
//    let KEY:String = "????????"  // TODO fill key
//    let STOREID:String = "?????????"         // TODO fill store id
//    let EMAIL:String = "????????"
//
    
     let KEY:String = "BwxtF~dq9L#xgWZb" //"????????"  // TODO fill key
      let STOREID:String = "21941" //"?????????"         // TODO fill store id
      let EMAIL:String = "girish.spryox@gmail.com"
      
    
    var paymentRequest:PaymentRequest?
    //var show:Bool = false;
    
    
    @IBOutlet var showCardBtn: UIButton!
    @IBOutlet var cardSv: UIStackView!
    @IBOutlet var amountTxt: UITextField!
    @IBOutlet var cardTxt: UILabel!
    
    @IBAction func showcardbtnPressed(_ sender: Any) {
        cardTxt.text = "**** **** **** " + getSavedData(key: "last4")
        if(cardSv.isHidden == true){
            cardSv.isHidden = false
            showCardBtn.setTitle("Hide",for: .normal)
        }else{
            cardSv.isHidden = true
            showCardBtn.setTitle("Show stored card",for: .normal)
        }
    }
    @IBAction func payBtnPressed(_ sender: Any) {
        paymentRequest = preparePaymentRequest()
       
        print(paymentRequest?.transCartid as Any)
        //print(paymentRequest?.transRef as Any)
        print(paymentRequest?.transDesc as Any)
      
        performSegue(withIdentifier: "TelrSegue", sender: paymentRequest)
    }
    
    
    @IBAction func payBtn2Pressed(_ sender: Any) {
    paymentRequest = preparePaymentRequest2()
    performSegue(withIdentifier: "TelrSegue", sender: paymentRequest)
}

override func viewDidLoad() {
    self.navigationController?.navigationBar.isHidden = true
    super.viewDidLoad()
    if(getSavedData(key: "last4").isEmpty){
        showCardBtn.isHidden = true
    }else{
        showCardBtn.isHidden = false
    }
    
}


override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? TelrController{
        destination.paymentRequest = paymentRequest!
    }
}

private func getSavedData(key:String) -> String{
    let defaults = UserDefaults.standard
    return defaults.string(forKey: key) ?? ""
}

//    func prepareRecurrentPaymentRequest() -> PaymentRequest{
//        let paymentReq = PaymentRequest()
//        paymentReq.key = KEY
//        paymentReq.store = STOREID
//        paymentReq.appId = "123456789"
//        paymentReq.appName = "TelrSDK"
//        paymentReq.appUser = "123456"
//        paymentReq.appVersion = "0.0.1"
//        paymentReq.transTest = "1"
//
//        paymentReq.transType = "sale"
//        paymentReq.transClass = "cont"
////        let model = self.cardsArray[self.selectedPaymentOption]
//        paymentReq.transRef = "040021600537"
//
//        paymentReq.transCartid = String(arc4random())
//        paymentReq.transDesc = "Test API"
//        paymentReq.transCurrency = "AED"
//        paymentReq.transAmount = amountTxt.text!
//        paymentReq.billingEmail = EMAIL
//
//
////        Other transaction details, such as cart ID and description, must be sent as per a normal Sale request.
//
//        return paymentReq
//    }
    
private func preparePaymentRequest() -> PaymentRequest{
    
    let paymentReq = PaymentRequest()
    paymentReq.key = KEY
    paymentReq.store = STOREID
    paymentReq.appId = "123456789"
    paymentReq.appName = "TelrSDK"
    paymentReq.appUser = "123456"
    paymentReq.appVersion = "0.0.1"
    paymentReq.transTest = "1"
    paymentReq.transType = "auth"
    paymentReq.transClass = "paypage"
    paymentReq.transCartid = String(arc4random())
    paymentReq.transDesc = "Test API"
    paymentReq.transCurrency = "AED"
    paymentReq.transAmount = amountTxt.text!
    //paymentReq.transLanguage = "en"
    paymentReq.billingEmail = EMAIL // TODO fill email
    paymentReq.billingFName = "Hany"
    paymentReq.billingLName = "Sakr"
    paymentReq.billingTitle = "Mr"
    paymentReq.city = "Dubai"
    paymentReq.country = "AE"
    paymentReq.region = "Dubai"
    paymentReq.address = "line 1"
    //paymentReq.billingPhone="8785643"
    paymentReq.language = "ar"
    return paymentReq
}

private func preparePaymentRequest2() -> PaymentRequest{

    let paymentReq = PaymentRequest()
    paymentReq.key = KEY
    paymentReq.store = STOREID
    paymentReq.appId = "123456789"
    paymentReq.appName = "TelrSDK"
    paymentReq.appUser = "123456"
    paymentReq.appVersion = "0.0.1"
    paymentReq.transTest = "1"
    paymentReq.transType = "paypage"
    paymentReq.transClass = "ecom"
    paymentReq.transCartid = String(arc4random())
    paymentReq.transDesc = "Test API"
    paymentReq.transCurrency = "AED"
    paymentReq.transAmount = amountTxt.text!
    paymentReq.transFirstRef = self.getSavedData(key: "firstref")
    paymentReq.transRef = self.getSavedData(key: "ref")
    paymentReq.billingEmail = EMAIL
    paymentReq.language = "ar"
    return paymentReq
}




}




