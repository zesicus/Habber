//
//  LoginViewController.swift
//  Habber
//
//  Created by Sunny on 12/15/15.
//  Copyright © 2015 Nine. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    //MARK: Outlets for UI Elements.
    @IBOutlet weak var usernameField:   UITextField!
    @IBOutlet weak var imageView:       UIImageView!
    @IBOutlet weak var passwordField:   UITextField!
    @IBOutlet weak var serverField:     UITextField!
    @IBOutlet weak var loginButton:     UIButton!
    
    //新增的登录旋转小菊花状态指示
    private let indicator = UIActivityIndicatorView()
    
    private let friendListTableViewController = FriendListTableViewController()
    
    //MARK: Global Variables for Changing Image Functionality.
    private var idx: Int = 0
    private let backGroundArray = [UIImage(named: "img1.jpg"),UIImage(named:"img2.jpg"), UIImage(named: "img3.jpg"), UIImage(named: "img4.jpg")]
    
    //MARK: View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        serverField.delegate = self
        
        usernameField.alpha = 0;
        passwordField.alpha = 0;
        loginButton.alpha   = 0;
        serverField.alpha = 0;
        
        //作者写的动态效果
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.usernameField.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.serverField.alpha = 1.0
            self.loginButton.alpha   = 0.9
            }, completion: nil)
        
        // Notifiying for Changes in the textFields
        usernameField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        serverField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        
        // Visual Effect View for background
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        visualEffectView.frame = self.view.frame
        visualEffectView.alpha = 0.5
        imageView.image = UIImage(named: "img1.jpg")
        imageView.addSubview(visualEffectView)
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "changeImage", userInfo: nil, repeats: true)
        self.loginButton(false)
        
        //这里用手写添加活动指示器，练练手写UI、、
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        indicator.center = CGPointMake(loginButton.bounds.size.width/2, loginButton.bounds.size.height/2)
        loginButton.addSubview(indicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        //自动填写文本框
        let defaults = NSUserDefaults.standardUserDefaults();
        if (defaults.objectForKey(USERID) != nil && defaults.objectForKey(PASS) != nil) {
            usernameField.text = String(defaults.objectForKey(USERID)!)
            passwordField.text = String(defaults.objectForKey(PASS)!)
            self.loginButton(true)
        }
        if (defaults.objectForKey(SERVER) != nil) {
            serverField.text = String(defaults.objectForKey(SERVER)!)
        }
        indicatorStop()
        //监听
        //登录服务器失败，弹出警示框
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectServerFailed", name: "connectServerFailed", object: nil)
        //认证成功，就可以跳转了
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hasAuthenticated", name: "hasAuthenticated", object: nil)
        //认证失败，弹出警示框
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticateFail", name: "authenticateFail", object: nil)
        //注册成功
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerSuccess", name: "registerSuccess", object: nil)
        //注册失败
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerFail", name: "registerFail", object: nil)
        //正在连接
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connecting", name: "connecting", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //控制小菊花的功能块
    func indicatorStop() {
        indicator.stopAnimating()
        indicator.hidden = true
        loginButton.setTitle("Login", forState: UIControlState.Normal)
    }
    
    func indicatorStart() {
        indicator.hidden = false
        loginButton.setTitle("", forState: UIControlState.Normal)
        indicator.startAnimating()
    }
    
    //MARK: - 通知的selector实现
    func connectServerFailed() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertView()
            alert.title = "Connection failed!"
            alert.delegate = nil
            alert.message = "Could not connect to server."
            alert.addButtonWithTitle("OK")
            alert.show()
            self.indicatorStop()
        }
    }
    
    func authenticateFail() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertView()
            alert.title = "Login failed!"
            alert.delegate = nil
            alert.message = "Wrong username or password"
            alert.addButtonWithTitle("OK")
            alert.show()
            self.indicatorStop()
        }
    }
    
    func hasAuthenticated() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.indicatorStop()
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
    func registerSuccess() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertView()
            alert.title = "Register success!"
            alert.delegate = nil
            alert.message = "Congratulation!"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func registerFail() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertView()
            alert.title = "Register failed!"
            alert.delegate = nil
            alert.message = "Wrong format!\nPlease follow the format like this:\nxxx@thinkdifferent.local\n\nBut...success or not depends\nthe mood of the server...😥"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func connecting() {
        indicatorStart()
    }
    
    //MARK: - 实现UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField || textField == passwordField || textField == serverField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - 获得xmppStream
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func xmppStream() -> XMPPStream {
        return self.getAppDelegate().xmppStream
    }
    //MARK: -
    
    //原作者写的login button动态效果
    func loginButton(enabled: Bool) -> () {
        func enable(){
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHex("#85c200", alpha: 1)
                }, completion: nil)
            loginButton.enabled = true
        }
        func disable(){
            loginButton.enabled = false
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHex("#333333",alpha :1)
                }, completion: nil)
        }
        return enabled ? enable() : disable()
    }
    
    func changeImage(){
        if idx == backGroundArray.count-1{
            idx = 0
        }
        else{
            idx++
        }
        let toImage = backGroundArray[idx];
        UIView.transitionWithView(self.imageView, duration: 3, options: .TransitionCrossDissolve, animations: {self.imageView.image = toImage}, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //这里不打算加上server，server默认localhost
    func textFieldDidChange() {
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty
        {
            self.loginButton(false)
        }
        else
        {
            self.loginButton(true)
        }
    }
    
    //MARK: - 按钮按下
    @IBAction func loginPressed(sender: UIButton) {
        if (usernameField.text != nil && passwordField.text != nil) {
            saveData()
            
            self.getAppDelegate().connect()
            
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
            serverField.resignFirstResponder()
        }
    }
    //MARK: - 注册
    
    //这里可以给一个注册的页面，添加一个注册的功能，我没有写、那就同步一下数据库吧。
    @IBAction func signupPressed(sender: AnyObject) {
        if (usernameField.text?.lengthOfBytesUsingEncoding(0) > 0  && passwordField.text?.lengthOfBytesUsingEncoding(0) > 0) {
            saveData()
            getAppDelegate().signup()
        } else {
            let alert = UIAlertView()
            alert.title = "Register"
            alert.delegate = nil
            alert.message = "You can sign up on this page\nJust fill the username and\npassword then tap again!\nPlease follow the format like this:\nxxx@thinkdifferent.local"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    //MARK: -
    
    //保存登录所有文本框上信息到数据库
    func saveData() {
        let defaults = NSUserDefaults.standardUserDefaults();
        defaults.setObject(usernameField.text, forKey: USERID)
        defaults.setObject(passwordField.text, forKey: PASS)
        if (!serverField.text!.isEqual("")) {
            defaults.setObject(serverField.text, forKey: SERVER)
        } else {
            defaults.setObject("localhost", forKey: SERVER)
        }
        //把登录用户数据保存到数据库
        defaults.synchronize()
    }
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        serverField.resignFirstResponder()
    }
    
    //MARK: - 执行Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "login") {
            let friendListTVC = (segue.destinationViewController as! UINavigationController).topViewController as! FriendListTableViewController
            friendListTVC.loginFlag = "success"
        }
    }
    //MARK: -
    
}

//Extension for Color to take Hex Values
extension UIColor{
    
    class func colorWithHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = NSScanner(string: hex)
        
        if hex.hasPrefix("#") {
            // skip '#' character
            scanner.scanLocation = 1
        }
        scanner.scanHexInt(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

}
