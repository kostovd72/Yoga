


import UIKit
import Parse
import FBSDKLoginKit
import ParseFacebookUtilsV4
class Login: UIViewController, UITextFieldDelegate, UIAlertViewDelegate
{
    
    // Views
    @IBOutlet var containerScrollView: UIScrollView!
    
    var userEmail = String()
    
    
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            dismiss(animated: false, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup layouts
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
        
        // Change placeholder's color
       
        
    }
    
    
    
    // Login Button
    @IBAction func loginButt(_ sender: AnyObject) {
        
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "Login2") as! Login2
        present(signupVC, animated: true, completion: nil)
    }
    
    
    @IBAction func facebookClicked(_ sender: Any) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"]) { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    if(FBSDKAccessToken.current() != nil)
                    {
                        let requestParameters = ["fields": "id, email, first_name, last_name"]
        
                        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
                        userDetails?.start(completionHandler: { (connection, result, error) in
                            if(error != nil){
                                print("\(error?.localizedDescription)")
                                return
                            }else{
                                let dict : NSDictionary = result as! NSDictionary
                                print(dict);
                                if let currentUser = PFUser.current(){
                                    let firstName = dict.object(forKey: "first_name") as! String
                                    let lastName = dict.object(forKey: "last_name") as! String
                                    let fullName = firstName  + lastName
                                    currentUser["fullName"] = fullName
                                    currentUser["email"] = dict.object(forKey : "email")
                                    currentUser.saveInBackground()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        })
                    }
                } else {
                    print("User logged in through Facebook!")
                     self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
        
    }
//          if(error != nil)
//            {
//                //Display an alert message
//                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert);
//                
//                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
//                
//                myAlert.addAction(okAction);
//                self.present(myAlert, animated:true, completion:nil);
//                
//                return
//            }
//            
//            print(user)
//            print("Current user token=\(FBSDKAccessToken.current().tokenString)")
//            
//            print("Current user id \(FBSDKAccessToken.current().userID)")
//            
//            if(FBSDKAccessToken.current() != nil)
//            {
//                let requestParameters = ["fields": "id, email, first_name, last_name"]
//                
//                let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
//                userDetails?.start(completionHandler: { (connection, result, error) in
//                    if(error != nil){
//                        print("\(error?.localizedDescription)")
//                        return
//                    }else{
//                        let dict : NSDictionary = result as! NSDictionary
//                        print(dict);
//                        if let currentUser = PFUser.current(){
//                            let firstName = dict.object(forKey: "first_name") as! String
//                            let lastName = dict.object(forKey: "last_name") as! String
//                            let fullName = firstName  + lastName
//                            currentUser["fullName"] = fullName
//                            currentUser["email"] = dict.object(forKey : "email")
//                            
//                            currentUser.saveInBackground()
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                })
//            }
//        }
//    }
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                
//                if fbloginresult.isCancelled == true
//                {
//                    return
//                }
//                
//                if fbloginresult.grantedPermissions != nil && (fbloginresult.grantedPermissions.contains("email"))
//                {
//                    self.getFBUserData()
//                }
//            }
//        }

//   }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name ,picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result!)
                    
                    if let resultDict = result as? NSDictionary {
                        self.showHUD("Loading...")
                        let strEmail = resultDict["email"] as? String
                        let strPass = (resultDict["first_name"] as? String)! + " " + (resultDict["last_name"] as? String)!
                        
                        PFUser.logInWithUsername(inBackground: strEmail!, password:strPass) { (user, error) -> Void in
                            // If Login successfull
                            if user != nil {
                                self.dismiss(animated: true, completion: nil)
                                self.hideHUD()
                                hudView.removeFromSuperview()
                                
                                // If Login failed. SignUp
                            } else {
                                let userForSignUp = PFUser()
                                userForSignUp.username = strEmail
                                userForSignUp.password = strPass
                                userForSignUp.email = strEmail
                                userForSignUp[USER_FULLNAME] = strPass
                                
                                userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                                    if error == nil {  // Successful Signup
                                        self.dismiss(animated: true, completion: nil)
                                        self.hideHUD()
                                        
                                    } else { // No signup, something went wrong
                                        self.simpleAlert("\(error!.localizedDescription)")
                                        self.hideHUD()
                                    }}

                                hudView.removeFromSuperview()
                            }}
                    }
                }
            })
        }
    }

    // AlertView
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Sign Up" {
            signupButt(self)
        }
        
        if alertView.buttonTitle(at: buttonIndex) == "Reset Password" {
            PFUser.requestPasswordResetForEmail(inBackground: "\(alertView.textField(at: 0)!.text!)")
            showNotifAlert()
        }
    }
     // SignUp Button
    @IBAction func signupButt(_ sender: AnyObject) {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
        present(signupVC, animated: true, completion: nil)
    }
    // Tap to Dismiss Keyboard
    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func showNotifAlert() {
        simpleAlert("You will receive an email shortly with a link to reset your password")
    }
}


