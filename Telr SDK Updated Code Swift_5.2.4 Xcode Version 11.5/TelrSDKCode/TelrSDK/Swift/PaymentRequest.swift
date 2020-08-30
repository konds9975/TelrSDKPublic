//
//  PaymentRequest.swift
//  Telr_SDK
//
//  Created by Staff on 5/24/17.
//  Copyright © 2017 Telr. All rights reserved.
//

import UIKit

open class PaymentRequest:NSObject{
    
    
    public var store = String()
    
    public var key = String()
    
    public var deviceType = String()
    
    public var deviceId = String()
    
    public var appId = String()
    
    public var appName = String()
    
    public var appUser = String()

    public var appVersion = String()
    
    public var transTest = String()
    
    public var transType = String()
    
    public var transClass = String()
    
    public var transCartid = String()
    
    public var transDesc = String()
    
    public var transCurrency = String()
    
    public var transAmount = String()
    
    public var billingEmail = String()
    
    public var billingFName = String()
    
    public var billingLName = String()
    
    public var billingTitle = String()
    
    public var city = String()
    
    public var country = String()

    public var region = String()
    
    public var address = String()
    
    public var language = String()
    
    public var transRef = String()
    
    public var transFirstRef = String()
    
    
    public override init(){}
        
}
