

import UIKit
import Parse



class PurchasedRecipesCell: UITableViewCell {
    
    // Views
    @IBOutlet weak var coverThumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}




// Account
class Account: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
    
    // Views
    @IBOutlet weak var noUserView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var favRecipesCollView: UICollectionView!
    
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    // Vars
    var purchasedArray = [PFObject]()
    var favRecipesArray = [PFObject]()
    var cellSize = CGSize()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            self.noUserView.isHidden = true
            self.mainView.isHidden = false
            
            // Call query
            self.queryFavoriteRecipes()
           self.fullNameLabel.text = "\(PFUser.current()![USER_FULLNAME]!)"
            
            
        } else {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(aVC, animated: true, completion: nil)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom TopBar Elements Right & left
        if let font : UIFont = UIFont(name: "Helvetica Neue", size: 12)
        {
            rightBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState.normal)
           
        }

        
        
        // Set cell size based on current device
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            cellSize = CGSize(width: view.frame.size.width/2 - 20, height: 195)
        } else  {
            // iPad
            cellSize = CGSize(width: view.frame.size.width/3 - 20, height: 218)
        }
        
    }
    
    
    
    
    
    // Query Favorites Recipes
    func queryFavoriteRecipes() {
        favRecipesCollView.isHidden = false
        favRecipesArray.removeAll()
        showHUD("Favorites...")
        
        let query = PFQuery(className: FAV_CLASS_NAME)
        query.whereKey(FAV_FAVORITED_BY, equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.favRecipesArray = objects!
                self.favRecipesCollView.reloadData()
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    
    
    // Favorites
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favRecipesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipesCell", for: indexPath) as! RecipesCell
        
        let favClass = favRecipesArray[indexPath.row]
        
        // Get Recipe Pointer
        var recipePointer = favClass[FAV_RECIPE_POINTER] as! PFObject
        do { recipePointer = try recipePointer.fetchIfNeeded() } catch {}
        
        // Get Title and Category
        cell.titleLabel.text = "\(recipePointer[EXERCISES_TITLE]!)"
        cell.categoryLabel.text = "\(recipePointer[EXERCISES_CATEGORY]!)"
        
        // Get 1st image
        let imageFile = recipePointer[EXERCISES_IMAGE1] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.coverImage.image = UIImage(data:imageData)
                }}})
        
        cell.favOutlet.tag = indexPath.row
        
        
        // Customize cell's layout
        cell.layer.cornerRadius = 0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 10, height: 10)
        cell.layer.shadowOpacity = 1
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    
    // Tap a Cell = Show Favorites
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let favClass = favRecipesArray[indexPath.row]
        
        // Get Recipe Pointer
        var recipePointer = favClass[FAV_RECIPE_POINTER] as! PFObject
        do { recipePointer = try recipePointer.fetchIfNeeded() } catch {}
        
        let rdVC = self.storyboard?.instantiateViewController(withIdentifier: "RecipeDetails") as! RecipeDetails
        rdVC.recipeObj = recipePointer
        self.navigationController?.pushViewController(rdVC, animated: true)
    }
    
    
    
    
    
    
    // Delete Favorites Button
    @IBAction func favButt(_ sender: AnyObject) {
        let butt = sender as! UIButton
        
        let favClass = favRecipesArray[butt.tag]
        
        favClass.deleteInBackground { (succ, error) in
            if error == nil {
                self.simpleAlert("Removed from your Favorites")
                self.favRecipesArray.remove(at: butt.tag)
                self.favRecipesCollView.reloadData()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }
        }
        
    }
    
    

    
    // Login Button
    @IBAction func loginButt(_ sender: AnyObject) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(loginVC, animated: true, completion: nil)
    }
    
    
    
    // Logout Button
    @IBAction func logoutButt(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Are you sure you want to logout?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.showHUD("Logout...")
            
            PFUser.logOutInBackground { (error) -> Void in
                if error == nil {
                    // Show the Login screen
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(loginVC, animated: true, completion: nil)
                }
                self.hideHUD()
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}







