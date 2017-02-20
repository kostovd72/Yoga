

import UIKit
import MessageUI


class AboutUs: UIViewController, MFMailComposeViewControllerDelegate
{

    
override func viewDidLoad() {
        super.viewDidLoad()


}


// Website Button
@IBAction func websiteButt(_ sender: AnyObject) {
    let MY_URL = URL(string: WEBSITE_URL)
    UIApplication.shared.openURL(MY_URL!)
}
    

    
// Mail Button
@IBAction func mailButt(_ sender: AnyObject) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([ADMIN_EMAIL_ADDRESS])
    mailComposer.setSubject("")
    mailComposer.setMessageBody("", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        present(mailComposer, animated: true, completion: nil)
    } else {
        simpleAlert("Your device cannot send emails. Please configure an email address into Settings > Mail, Contacts, Calendars.")
    }
}
    
// Email delegate
func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResult.sent.rawValue:
            outputMessage = "Mail sent"
        case MFMailComposeResult.failed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
    
    simpleAlert(outputMessage)
    dismiss(animated: false, completion: nil)
}
    
    
    
// Social Button
@IBAction func socialButtons(_ sender: AnyObject) {
        let butt = sender as! UIButton
        
    switch butt.tag {
        case 0:
            let MY_URL = URL(string: FACEBOOK_URL)
            UIApplication.shared.openURL(MY_URL!)
        case 1:
            let MY_URL = URL(string: TWITTER_URL)
            UIApplication.shared.openURL(MY_URL!)
            
    default:break }
}
    
    
     
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
