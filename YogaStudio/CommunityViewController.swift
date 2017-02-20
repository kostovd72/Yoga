

import UIKit
import Parse

class CommunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Views
    @IBOutlet weak var tableView: UITableView!
    
    // vars
    var categoryArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        //self.tableView.separatorStyle = .none
        
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(aVC, animated: true, completion: nil)
        }
        
        // remove extra lines, make separator touch edge
        tableView.tableFooterView = UIView()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        queryCategories()

    }

    func queryCategories() {
        
        showHUD("Loading...")
        let query = PFQuery(className: "Community_Categories")
        
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.categoryArray = objects!
                self.tableView.reloadData()
                self.hideHUD()
                
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
                
            }}
    }
    
    
    
    // TableView datasource delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = "\(categoryArray[indexPath.row]["name"]!)"
        let category = categoryArray[indexPath.row]
        let isPremium: Bool = category.value(forKey: "premium") as! Bool
        if isPremium {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "lock.png"), for: .normal)
            button.contentMode = .scaleAspectFit
            cell.accessoryView = button as UIView
        }
        

        return cell
    }
    
    // go to the category when select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categoryArray[indexPath.row]
        let isPremium: Bool = category.value(forKey: "premium") as! Bool
        if isPremium {
            let payVC = storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
            navigationController?.pushViewController(payVC, animated: true)
        }else {
            let selectedCell = tableView.cellForRow(at: indexPath)!
            let categoryStr = selectedCell.textLabel!.text!
            let destVC = storyboard?.instantiateViewController(withIdentifier: "Topics") as! Topics
            destVC.category = categoryStr
            navigationController?.pushViewController(destVC, animated: true)

        }
        
        
    }
    
 }
