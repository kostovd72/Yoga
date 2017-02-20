
import UIKit
import Parse

class Reply: UIViewController, UITextViewDelegate {

    
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var postTitle: String!
    var category: String!
    var topic: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set navigation bar
        // set back button
        let backButt = UIBarButtonItem()
        let font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        backButt.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        backButt.title = "BACK"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButt
        navigationController?.navigationBar.tintColor = .black
        //navigationController?.navigationBar.barTintColor = .purple
        
        
        // set reply button
        let shareButt = UIButton(type: UIButtonType.custom)
        shareButt.adjustsImageWhenHighlighted = false
        shareButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        shareButt.addTarget(self, action: #selector(doneButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButt)
        shareButt.setTitle("DONE", for: UIControlState.normal)
        shareButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        shareButt.setTitleColor(UIColor.black, for:UIControlState.normal)
        
        navigationItem.title = "Reply"
        
        commentTextView.delegate = self
        commentTextView.becomeFirstResponder()
    }
    
    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func doneButton(_ sender:UIButton) {
        
        let description = commentTextView.text ?? ""
        if description.isEmpty {
            let alert = UIAlertController(title: "Empty Field",
                                          message: "Please leave your comments",
                                          preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                return
            })
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // save comment to parse
        showHUD("Saving...")
        
        let comment = PFObject(className: "Community_Comments")
        comment["Title"] = postTitle
        comment["Description"] = description
        comment["Category"] = category
        comment["username"] = "\(PFUser.current()![USER_FULLNAME]!)"
        comment["User"] = PFUser.current()
        comment["Topic"] = topic
        comment["deleted"] = false
        
        comment.saveInBackground { (saved:Bool, error:Error?) -> Void in
            if saved {
                //self.hideHUD()
                
            } else {
                
                self.hideHUD()
                let alert = UIAlertController(title: "",
                                              message: "Save Failed",
                                              preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    return
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // increase no_of_comments of topic
        let query = PFQuery(className: "Community_Topics")
        query.getObjectInBackground(withId: self.topic.objectId!) {
            (object, error) -> Void in
            
            if error != nil {
                self.hideHUD()
                print(error)
            }else if let object = object {
                self.hideHUD()
                var comments = object["No_of_comments"] as! Int
                comments += 1
                object["No_of_comments"] = comments
                object.saveInBackground() { (saved:Bool, error:Error?) -> Void in
                    if saved {
                        self.didSave()
                    }
                }
            }
        }
    }
    
    func didSave(){
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // UITextViewDelegate, Hide the keyboard when press return key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }


}
