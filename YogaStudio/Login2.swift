
import UIKit
import Parse
class Login2: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
        
        // Change placeholder's color
        let color = UIColor.gray
        usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName: color])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName: color])

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func singleTap(_ sender: Any) {
        dismissKeyboard()
    }
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
       
    }
    @IBAction func login(_ sender: Any) {
        passwordTxt.resignFirstResponder()
        showHUD("Loading...")
        
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
            // If Login successfull
            if user != nil {
                self.dismiss(animated: true, completion: nil)
                hudView.removeFromSuperview()
                
                // If Login failed. Try again or SignUp
            } else {
                let alert = UIAlertView(title: APP_NAME,
                                        message: "\(error!.localizedDescription)",
                    delegate: self,
                    cancelButtonTitle: "Retry",
                    otherButtonTitles: "Sign Up")
                alert.show()
                hudView.removeFromSuperview()
            }}

        
    }
    // Textfields Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
        if textField == passwordTxt {  passwordTxt.resignFirstResponder()     }
        
        return true
    }

    @IBAction func backButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func forgotPasswButt(_ sender: AnyObject) {
        let alert = UIAlertView(title: APP_NAME,
                                message: "Type your email address you used to register.",
                                delegate: self,
                                cancelButtonTitle: "Cancel",
                                otherButtonTitles: "Reset Password")
        alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        alert.show()
    }
    // Notification for Password reet

    func showNotifAlert() {
        simpleAlert("You will receive an email shortly with a link to reset your password")
    }

}
