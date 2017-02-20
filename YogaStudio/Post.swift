

import UIKit
import Parse

class Post: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    
    // MARK - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // vars
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        
        // set navigation bar
        // set back button
        let backButt = UIBarButtonItem()
        let font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        backButt.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        backButt.title = "BACK"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButt
        navigationController?.navigationBar.tintColor = .black
        //navigationController?.navigationBar.barTintColor = .purple
        
        
        // set new button
        let shareButt = UIButton(type: UIButtonType.custom)
        shareButt.adjustsImageWhenHighlighted = false
        shareButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        shareButt.addTarget(self, action: #selector(postButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButt)
        shareButt.setTitle("POST", for: UIControlState.normal)
        shareButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        shareButt.setTitleColor(UIColor.black, for:UIControlState.normal)
        
        navigationItem.title = category
        
        titleTextField.becomeFirstResponder()
        
       
    }
  
    
    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func postButton(_ sender:UIButton) {
        
        let title = titleTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        
        // check if fields are empty
        if title.isEmpty || description.isEmpty {
            let alert = UIAlertController(title: "Empty Field",
                                          message: "Please fill all fields",
                                          preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                return
            })
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // save topic to parse
        showHUD("Saving...")
        let topic = PFObject(className: "Community_Topics")
        topic["Title"] = title
        topic["Description"] = description
        topic["No_of_comments"] = 0
        topic["category"] = category
        topic["username"] = "\(PFUser.current()![USER_FULLNAME]!)"
        topic["deleted"] = false
        topic["User"] = PFUser.current()
        
        topic.saveInBackground { (saved:Bool, error:Error?) -> Void in
            if saved {
                self.hideHUD()
                self.didSave()
                
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
        
    }

    func didSave(){
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // UITextFieldDelegate, UITextViewDelegate, Hide the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
