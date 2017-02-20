



import UIKit
import Parse


class SignUp: UIViewController, UITextFieldDelegate
{
    
    // Views
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var fullnameTxt: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup layout views
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
        
        // Change placeholder's color
        let color = UIColor.gray
        usernameTxt.attributedPlaceholder = NSAttributedString(string: "Type a Username", attributes: [NSForegroundColorAttributeName: color])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Type a Password", attributes: [NSForegroundColorAttributeName: color])
        fullnameTxt.attributedPlaceholder = NSAttributedString(string: "Type your Fullname", attributes: [NSForegroundColorAttributeName: color])
        
    }
    
    
    // Tap to Dismiss Keyboard
    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
    }
    
    
    
    // SignUp Button
    @IBAction func signupButt(_ sender: AnyObject) {
        dismissKeyboard()
        showHUD("SignUp...")
        
        // If Empty field = No sign Up
        if usernameTxt.text == "" || passwordTxt.text == "" || fullnameTxt.text == "" {
            self.simpleAlert("You must fill all fields to sign up")
            self.hideHUD()
            
        } else {
            
            let userForSignUp = PFUser()
            userForSignUp.username = usernameTxt.text
            userForSignUp.password = passwordTxt.text
            userForSignUp.email = usernameTxt.text
            userForSignUp[USER_FULLNAME] = fullnameTxt.text
            
            userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                if error == nil {  // Successful Signup
                    self.dismiss(animated: true, completion: nil)
                    self.hideHUD()
                    
                } else { // No signup, something went wrong
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
        }
    }
    
    
    
    
    
    // Textfields Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
        if textField == passwordTxt {  fullnameTxt.becomeFirstResponder()     }
        if textField == fullnameTxt    {  fullnameTxt.resignFirstResponder()     }
        return true
    }
    
    
    
    // Back Button
    @IBAction func backButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // Terms of Use Button
    @IBAction func touButt(_ sender: AnyObject) {
        let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(touVC, animated: true, completion: nil)
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


