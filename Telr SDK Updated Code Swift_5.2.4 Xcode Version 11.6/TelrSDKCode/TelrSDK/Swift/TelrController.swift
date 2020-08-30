//
//  TelrController.swift
//  Telr_SDK
//
//  Created by Staff on 5/24/17.
//  Copyright © 2017 Telr. All rights reserved.
//

import UIKit
import AEXML
import SwiftyXMLParser

import WebKit

public class TelrController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {


    @objc var webView : WKWebView = WKWebView()
    //@objc var contentController = WKUserContentController()
    var utility:Utility = Utility()
    
    private var _paymentRequest:PaymentRequest?
    private var _code:String?
    private var _status:String?
    private var _avs:String?
    private var _ca_valid:String?
    private var _cardCode:String?
    private var _cardLast4:String?
    private var _cvv:String?
    private var _tranRef:String?
    private var _transFirstRef:String?
    private var _trace:String?
    private var _cardFirst6:String?

    public var paymentRequest:PaymentRequest{
        get{
            return _paymentRequest!
        }
        set{
            _paymentRequest = newValue
            _paymentRequest?.deviceType = "iPhone"
            _paymentRequest?.deviceId = UIDevice.current.identifierForVendor!.uuidString
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.async {
            self.createWebView()
            
        }
        self.loadPaymentPage()
        
    }
    
    
    @objc func createWebView() {

//        let source = "var meta = document.createElement('meta');" +
//            "meta.name = 'viewport';" +
//            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
//            "var head = document.getElementsByTagName('head')[0];" +
//        "head.appendChild(meta);"
//
//        let script = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
//
//        let userContentController = WKUserContentController()
//        userContentController.addUserScript(script)
        
        let configuration = WKWebViewConfiguration()
        
        let viewBack = UIView()
        viewBack.backgroundColor = .white
        viewBack.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.frame = CGRect(x: 0, y: 20, width: viewBack.bounds.width, height: viewBack.bounds.height+20)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        webView.scrollView.delegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.isDirectionalLockEnabled = true
        webView.backgroundColor = UIColor.white
        webView.isMultipleTouchEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        viewBack.addSubview(webView)
        self.view.addSubview(viewBack)
        self.showActivityIndicatory(uiView: self.webView)
        
    }
    var actInd: UIActivityIndicatorView?
    func showActivityIndicatory(uiView: UIView) {
        actInd = UIActivityIndicatorView()
        actInd?.frame = CGRect(x: 0.0, y: -20, width: 40.0, height: 40.0);
        actInd?.center = uiView.center
        actInd?.hidesWhenStopped = true
        actInd?.style =
            UIActivityIndicatorView.Style.white
        actInd?.color = .black
        uiView.addSubview(actInd!)
        actInd?.startAnimating()
    }
    //MARK:- WKNavigationDelegate Methods

    //Equivalent of shouldStartLoadWithRequest:
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?

        actInd?.startAnimating()
             actInd?.isHidden = false
        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        print("decidePolicyFor - url: \(url)")

        //Uncomment below code if you want to open URL in safari
        /*
        if navigationAction.navigationType == .linkActivated, url.absoluteString.hasPrefix("https://developer.apple.com/") {
            action = .cancel  // Stop in WebView
            UIApplication.shared.open(url)
        }
        */
    }

    //Equivalent of webViewDidStartLoad:
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        actInd?.startAnimating()
             actInd?.isHidden = false
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
    }

    //Equivalent of didFailLoadWithError:
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        actInd?.stopAnimating()
             actInd?.isHidden = true
        let nserror = error as NSError
        if nserror.code != NSURLErrorCancelled {
            webView.loadHTMLString("Page Not Found", baseURL: URL(string: "https://developer.apple.com/"))
            
        }
    }

   

    func webViewDidStartLoad(_ : WKWebView) {
        actInd?.startAnimating()
        actInd?.isHidden = false
    }

    func webViewDidFinishLoad(_ : WKWebView){
        actInd?.stopAnimating()
       actInd?.isHidden = true
      
    }

    @objc func loadPaymentPage(){
        
            if(!self.utility.isJailbroken()){
            //activityIndicator.startAnimating()
                let xml:AEXMLDocument = self.initiatePaymentGateway(paymentRequest:self.paymentRequest)
            let data = xml.xml.data(using: .utf8)
            //let url = URL(string:"https://secure.innovatepayments.com/gateway/mobile.xml")
            let url = URL(string:"https://secure.telr.com/gateway/mobile.xml")
            if let newurl = url{
                var request = URLRequest(url: newurl)
                request.httpMethod = "post"
                request.httpBody = data
                
                
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                        
                        if let data = data{
                                         let xmlresponse = XML.parse(data)
                                         if let message = xmlresponse["mobile","auth","message"].text{
                                             self.showResultView(message:message)
                                         }else{
                                             let start = xmlresponse["mobile","webview","start"]
                                             let code = xmlresponse["mobile","webview","code"]
                                             self._code = code.text!
                                             let newurl = URL(string:start.text!)
                                             let newrequest = URLRequest(url: newurl!)
                                             DispatchQueue.main.async {
                                             self.webView.load(newrequest)
                                            }
                                         }
                                       }
                       
                    } catch {
                        print("JSON Serialization error")
                    }
                }).resume()
                
                
            }
        }else{
            print("jail broken ...")
            self.showResultView(message:"Your device has a security issue, you cannot use the app.")
        }
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        actInd?.stopAnimating()
        actInd?.isHidden = true
        //self.activityIndicator.stopAnimating()
        if (webView.url?.path.contains("webview_close.html"))!{
            self.checkStatus(key: self.paymentRequest.key, store: self.paymentRequest.store, complete: self._code!){
                done in
                let when = DispatchTime.now() + 0  // No waiting time
                DispatchQueue.main.asyncAfter(deadline: when) {
                    //let resultController = self.storyboard?.instantiateViewController(withIdentifier: "ResultController") as! ResultController
                    let resultController = self.loadController(name:"ResultController") as! TelrResponseController
                   
                    if(done){
                        resultController.message = "Your transaction is successful :" + self._trace!
                        
                    }else{
                        resultController.message = "Your transaction is failed : " + self._trace!
                    }
                    resultController.code = self._code
                    resultController.status = self._status
                    resultController.ca_valid = self._ca_valid
                    resultController.avs = self._avs
                    resultController.cardCode = self._cardCode
                    resultController.cardLast4 = self._cardLast4
                    resultController.cvv = self._cvv
                    resultController.tranRef = self._tranRef
                    resultController.transFirstRef = self._transFirstRef
                    resultController.trace = self._trace
                    resultController.cardFirst6 = self._cardFirst6
                    //self.present(resultController, animated: false, completion: nil)
                    //self.dismiss(animated: true)
                    self.navigationController?.pushViewController(resultController, animated: true)
                    //self.present(resultController, animated: true, completion: nil)
                    //self.loadController(name: "resultController")
 
                }
            }
        }
        
        let viewPortjs = "var myCustomViewport = 'width = " + String(describing: self.webView.frame.size.width) +
            "px'; " +
            "var viewportElement = document.querySelector('meta[name=viewport]');" +
            "if (viewportElement) {viewportElement.content = myCustomViewport;} " +
            "else {viewportElement = document.createElement('meta');" +
            "viewportElement.name = 'viewport';" +
            "viewportElement.content = myCustomViewport;" +
        "document.getElementsByTagName('head')[0].appendChild(viewportElement);}"
        
        self.webView.evaluateJavaScript(viewPortjs as String, completionHandler: { (response : AnyObject?, error: NSError?) -> Void in
            
            print(response ?? "R")
            print(error ?? "E")
            } as? (Any?, Error?) -> Void)

    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return nil
    }
    
    @objc public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        viewWillTransitionToSize(size: size, withTransitionCoordinator: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            
            //print(self.webView.url!.description)
            
            let viewPortjs = "var myCustomViewport = 'width = " + String(describing: self.webView.frame.size.width) +
                "px'; " +
                "var viewportElement = document.querySelector('meta[name=viewport]');" +
                "if (viewportElement) {viewportElement.content = myCustomViewport;} " +
                "else {viewportElement = document.createElement('meta');" +
                "viewportElement.name = 'viewport';" +
                "viewportElement.content = myCustomViewport;" +
            "document.getElementsByTagName('head')[0].appendChild(viewportElement);}"
            
            self.webView.evaluateJavaScript(viewPortjs as String, completionHandler: { (response : AnyObject?, error: NSError?) -> Void in
                
                print(response ?? "R")
                print(error ?? "E")
                } as? (Any?, Error?) -> Void)
            
        }, completion: nil)
    }

    
    private func loadController(name:String) -> UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: name)
        return controller
    }

    private func showResultView(message:String) -> Void {
        DispatchQueue.main.async(execute: {
            let resultController = self.storyboard?.instantiateViewController(withIdentifier: "ResultController") as! TelrResponseController
            resultController.message = message
            self.present(resultController, animated: true, completion: nil)
        });
    }
    
    
    private func checkStatus(key:String, store:String, complete:String, completionHandler:@escaping (Bool) -> ()) -> Void{
        //let completeURL = "https://secure.innovatepayments.com/gateway/mobile_complete.xml"
        let completeURL = "https://secure.telr.com/gateway/mobile_complete.xml"
        let xml:AEXMLDocument = initiateStatusRequest(key:key, store:store, complete: complete)
        let data = xml.xml.data(using: .utf8)
        let url = URL(string:completeURL)
        if let newurl = url{
            var request = URLRequest(url: newurl)
            request.httpMethod = "post"
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    
                    if let data = data{
                        
                        let str = String(decoding: data, as: UTF8.self)
                                       let xmlresponse = XML.parse(data)
                        
                        print("====5===\(str )=======")
                        print("=======\(xmlresponse.description )=======")
                        print("=======\(xmlresponse.all )=======")
                        print("=======\(xmlresponse.attributes )=======")
                        print("=======\(xmlresponse.element )=======")
                                       let statusMessage = xmlresponse["mobile","auth","message"]
                                       if statusMessage.text == "Authorised"{
                                           completionHandler(true)
                                       }else{
                                           completionHandler(false)
                                       }
                                       self._code = xmlresponse["mobile","auth","code"].text
                                       self._status = xmlresponse["mobile","auth","status"].text
                                       self._avs = xmlresponse["mobile","auth","avs"].text
                                       self._ca_valid = xmlresponse["mobile","auth","ca_valid"].text
                                       self._cardCode = xmlresponse["mobile","auth","cardcode"].text
                                       self._cardLast4 = xmlresponse["mobile","auth","cardlast4"].text
                                       self._cvv = xmlresponse["mobile","auth","cvv"].text!
                                       self._tranRef = xmlresponse["mobile","auth","tranref"].text
                                        self._transFirstRef = xmlresponse["mobile","auth","tranfirstref"].text
                                       self._trace = xmlresponse["mobile","trace"].text
                                       self._cardFirst6 = xmlresponse["mobile","auth","cardfirst6"].text
                                   }
                   
                } catch {
                    print("JSON Serialization error")
                }
            }).resume()
            
        }
    }
    
    private func initiateStatusRequest(key:String, store:String, complete:String) -> AEXMLDocument{
        let xml = AEXMLDocument()
        let mobile = xml.addChild(name: "mobile")
        mobile.addChild(name:"store",value:store)
        mobile.addChild(name:"key", value:key)
        mobile.addChild(name:"complete", value:complete)
        return xml
    }
    
    
    private func initiatePaymentGateway(paymentRequest: PaymentRequest) -> AEXMLDocument{
        
        let xml = AEXMLDocument()
        let mobile = xml.addChild(name: "mobile")
        mobile.addChild(name: "store", value: paymentRequest.store)
        mobile.addChild(name: "key", value: paymentRequest.key)
        
        let device = mobile.addChild(name: "device")
        device.addChild(name:"type", value:paymentRequest.deviceType)
        device.addChild(name:"id", value:paymentRequest.deviceId)
        
        let app = mobile.addChild(name:"app")
        app.addChild(name:"id", value:paymentRequest.appId)
        app.addChild(name:"name", value:paymentRequest.appName)
        app.addChild(name:"user", value:paymentRequest.appUser)
        app.addChild(name:"version", value:paymentRequest.appVersion)
        app.addChild(name:"sdk", value:"SDK ver 2.0")
        
        let tran = mobile.addChild(name:"tran")
        tran.addChild(name:"test", value:paymentRequest.transTest)
        tran.addChild(name:"type", value:paymentRequest.transType)
        tran.addChild(name:"class", value:paymentRequest.transClass)
        tran.addChild(name:"cartid", value:paymentRequest.transCartid) // randon number
        tran.addChild(name:"description", value:paymentRequest.transDesc)
        tran.addChild(name:"currency", value:paymentRequest.transCurrency)
        tran.addChild(name:"amount", value:paymentRequest.transAmount)
        tran.addChild(name:"version",value:"2")
        tran.addChild(name: "language", value: paymentRequest.language)
        tran.addChild(name: "ref", value: paymentRequest.transRef)
        tran.addChild(name: "firstref", value: paymentRequest.transFirstRef)
        
        let billing = mobile.addChild(name:"billing")
        billing.addChild(name:"email",value:paymentRequest.billingEmail)
        
        let name = billing.addChild(name:"name")
        name.addChild(name:"first", value:paymentRequest.billingFName)
        name.addChild(name:"last",value:paymentRequest.billingLName)
        name.addChild(name:"title",value:paymentRequest.billingTitle)
        
        let address = billing.addChild(name:"address")
        address.addChild(name:"city", value:paymentRequest.city)
        address.addChild(name:"country", value:paymentRequest.country)
        address.addChild(name:"region", value:paymentRequest.region)
        address.addChild(name:"line1", value:paymentRequest.address)
        
        //print(xml.xml)
        
        return xml
    }


    
}
