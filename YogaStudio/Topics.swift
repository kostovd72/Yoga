

import UIKit
import Parse

class Topics: UITableViewController {
    
    // vars
    var category: String!
    var topicArray = [PFObject]()

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
        
        
        // set new button
        let shareButt = UIButton(type: UIButtonType.custom)
        shareButt.adjustsImageWhenHighlighted = false
        shareButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        shareButt.addTarget(self, action: #selector(newButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButt)
        shareButt.setTitle("NEW", for: UIControlState.normal)
        shareButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        shareButt.setTitleColor(UIColor.black, for:UIControlState.normal)
        
        navigationItem.title = category
        
        // remove extra lines, make separator touch edge
        tableView.tableFooterView = UIView()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        queryTopics()
    }

    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func newButton(_ sender:UIButton) {
        
        let destVC = storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
        destVC.category = category
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func queryTopics() {
        
        showHUD("Loading...")
        let query = PFQuery(className: "Community_Topics")
        
        query.whereKey("deleted", equalTo: false)
        query.whereKey("category", equalTo: self.category)
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.topicArray = objects!
                
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
       
        return self.topicArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as! TopicCell
        
        cell.titleLabel.text = "\(topicArray[indexPath.row]["Title"]!)"
        cell.usernameLabel.text = "\(topicArray[indexPath.row]["username"]!)"

        cell.descriptionLabel.textContainer.maximumNumberOfLines = 2
        cell.descriptionLabel.textContainer.lineBreakMode = .byTruncatingTail
        cell.descriptionLabel.text = "\(topicArray[indexPath.row]["Description"]!)"
        cell.descriptionLabel.isUserInteractionEnabled = false
        
        
        let createdAt = topicArray[indexPath.row].createdAt
        let timeago = timeAgoSince(createdAt!)
        cell.dateLabel.text = timeago
        
        cell.commentLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
        cell.commentLabel.text = "\(topicArray[indexPath.row]["No_of_comments"]!)" + " Comments"

        return cell
    }
    
    // select cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destVC = storyboard?.instantiateViewController(withIdentifier: "SingleTopic") as! SingleTopic
        
        destVC.category = self.category
        destVC.postTitle = "\(topicArray[indexPath.row]["Title"]!)"
        destVC.topic = topicArray[indexPath.row]
        navigationController?.pushViewController(destVC, animated: true)
 
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
  }
