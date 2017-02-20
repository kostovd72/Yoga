
import UIKit
import Parse

class SingleTopic: UITableViewController {
    
    var postTitle: String!
    var category: String!
    
    var commentArray = [PFObject]()
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
        let replyButt = UIButton(type: UIButtonType.custom)
        replyButt.adjustsImageWhenHighlighted = false
        replyButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        replyButt.addTarget(self, action: #selector(replyButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: replyButt)
        replyButt.setTitle("REPLY", for: UIControlState.normal)
        replyButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        replyButt.setTitleColor(UIColor.black, for:UIControlState.normal)
 
        navigationItem.title = category
 
        // remove extra lines, make separator touch edge
        tableView.tableFooterView = UIView()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
    
    }

    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
 
    func replyButton(_ sender:UIButton) {
        
        let destVC = storyboard?.instantiateViewController(withIdentifier: "Reply") as! Reply
        
        destVC.category = self.category
        destVC.postTitle = self.postTitle
        destVC.topic = self.topic
        
        navigationController?.pushViewController(destVC, animated: true)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshTopic()
    }
    
    // update topic states such as number of comments, next query comments
    func refreshTopic()
    {
        showHUD("Loading...")
        
        topic.fetchInBackground { (object, error)-> Void in
            if error == nil{
               self.queryComments()
            }
        }
    }
    
    func queryComments() {
        
        let query = PFQuery(className: "Community_Comments")
        
        query.whereKey("Category", equalTo: self.category)
        query.whereKey("Title", equalTo: self.postTitle)
        query.whereKey("deleted", equalTo: false)
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.commentArray = objects!
                self.commentArray.insert(self.topic, at: 0)
                
                self.tableView.reloadData()
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.commentArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as! TopicCell
        
        cell.usernameLabel.text = "\(commentArray[indexPath.row]["username"]!)"
        cell.descriptionLabel.text = "\(commentArray[indexPath.row]["Description"]!)"
        
        let createdAt = commentArray[indexPath.row].createdAt
        let timeago = timeAgoSince(createdAt!)
        cell.dateLabel.text = timeago
        cell.titleLabel.text = ""
        cell.commentLabel.text = ""
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            cell.descriptionLabel.backgroundColor =  UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            cell.titleLabel.text = "\(commentArray[indexPath.row]["Title"]!)"
            cell.commentLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
            cell.commentLabel.text = "\(commentArray[indexPath.row]["No_of_comments"]!)" + " Comments"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
