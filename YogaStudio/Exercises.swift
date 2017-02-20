

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox
import StoreKit
import SwiftyStoreKit


// Global vars
var categoryStr = String()
var shoppingArray = [String]()



class Recipes: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, GADBannerViewDelegate
{
    var purchaseSuccess : Bool = false

    // Views
    @IBOutlet weak var recipesCollView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    // AdMob Banner View
    let adMobBannerView = GADBannerView()
    
    // Vars
    var recipesArray = [PFObject]()
    var favArray = [PFObject]()
    var cellSize = CGSize()
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        let circle = UIView()
        
        var progressCircle = CAShapeLayer()
        
        let circlePath = UIBezierPath(ovalIn: circle.bounds)
        
        progressCircle = CAShapeLayer ()
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = UIColor.green.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 5.0
        
        circle.layer.addSublayer(progressCircle)
        
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 0.2
        animation.duration = 3
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        progressCircle.add(animation, forKey: "ani")
        
        
        
        if PFUser.current() != nil {
            if categoryStr != "" {
                self.searchBar.text = ""
                if categoryStr == "All Exercises" { categoryStr = "" }
                
                self.queryRecipes(categoryStr)
                
                // Query all YogaExercise at app startup
            } else {
                if firstStartup {
                    self.queryRecipes("")
                    firstStartup = false
                }
            }
            
            
        } else {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(aVC, animated: true, completion: nil)
        }
        print("Category: \(categoryStr)")
        
        if(UserDefaults.standard.value(forKey: "premium") != nil){
            purchaseSuccess = UserDefaults.standard.value(forKey: "premium")! as! Bool
        }
        
        SwiftyStoreKit.verifyReceipt(password: "b2a7a7d355de45de936a76c61631db8c") { result in
            
            var didPurchase: Bool = false
            
            if case .success(let receipt) = result {
                let purchaseAnual = SwiftyStoreKit.verifySubscription(
                    productId: "com.nomind.yoga.weightloss.annual",
                    inReceipt: receipt,
                    validUntil: Date())
                let purchaseMonthly = SwiftyStoreKit.verifySubscription(
                    productId: "com.nomind.yoga.weightloss.monthly",
                    inReceipt: receipt,
                    validUntil: Date())
                // each result is either .purchased(expiryDate), .expired(expiredDate) or .notPurchased
                // use this to decide what to do
                switch purchaseAnual {
                case .purchased(let _):
                    print("Product is purchased.")
                    didPurchase = true;
                    
                case .notPurchased:
                    print("The user has never purchased this product")
                    UserDefaults.standard.setValue(false, forKey: "premium")
                    
                default :
                    
                    print("default")
                    
                }
                
                
                switch purchaseMonthly {
                case .purchased(let _):
                    print("Product is purchased.")
                    didPurchase = true;
                    
                    
                case .notPurchased:
                    print("The user has never purchased this product")
                    
                default :
                    
                    print("default")
                    
                }
                
                UserDefaults.standard.setValue(didPurchase, forKey: "premium")
                
                
                self.purchaseSuccess = didPurchase;
                self.recipesCollView.reloadData()
                
                print("purchaseAnual = \(purchaseAnual)")
                print("purchaseMonthly = \(purchaseMonthly)")
                
            }
        }

        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset search text
        searchBar.frame.origin.y = -60
        searchBar.text = ""
        
        
        
        // Init ad banners
        initAdMobBanner()
        
        // Set cell size based on current device
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            cellSize = CGSize(width: view.frame.size.width - 20, height: 195)
        } else  {
            // iPad
            cellSize = CGSize(width: 450, height: 200)
        }
        
        // Init ad banners
        initAdMobBanner()
        
    }
    // Query YogaExercise
    func queryRecipes(_ searchText:String) {
        showHUD("Searching...")
        
        let query = PFQuery(className: EXERCISES_CLASS_NAME)
        
        if searchBar.text != "" {
            let keywords = searchText.lowercased().components(separatedBy: " ") as [String]
            query.whereKey(EXERCISES_TITLE_LOWERCASE, contains:  "\(keywords[0])")
        }
        
        if categoryStr != "" {
            query.whereKey(EXERCISES_CATEGORY, equalTo: searchText)
        }
        
        
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.recipesArray = objects!
                self.recipesCollView.reloadData()
                
                // Hide/show the nothing found Label
                if self.recipesArray.count == 0 { self.nothingFoundLabel.isHidden = false
                } else { self.nothingFoundLabel.isHidden = true }
                
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        
    }
    // ViewDelegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipesCell", for: indexPath) as! RecipesCell
        
        let recipeRecord = recipesArray[indexPath.row]
        
        
        // Get data
        cell.titleLabel.text = "\(recipeRecord[EXERCISES_TITLE]!)"
        cell.categoryLabel.text = "\(recipeRecord[EXERCISES_CATEGORY]!)"
        cell.cookingLabel.text = "\(recipeRecord[EXERCISES_TIME]!)"
        
        cell.cookingLabel.layer.cornerRadius = 8
        cell.cookingLabel.layer.borderColor = UIColor.white.cgColor
        
        cell.lockButton.tag = indexPath.row
        cell.lockButton.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        
        cell.cookingLabel.layer.backgroundColor = UIColor(red: 73/255.0, green: 205/255.0, blue: 226/255.0, alpha: 0.95).cgColor
        
        // Get 1st image
        let imageFile = recipeRecord[EXERCISES_IMAGE1] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.coverImage.image = UIImage(data:imageData)
                }}})
        
        
        // Cell's layout
        cell.layer.cornerRadius = 0
        print(recipeRecord["premium"])
        let isPremiumMember : Bool = recipeRecord.value(forKey: "premium") as! Bool
        if self.purchaseSuccess == false && isPremiumMember == true{
            cell.lockButton.isHidden = false
        }else{
            cell.lockButton.isHidden = true
        }
        
        return cell
    }
    func onLockBtn() {
        print("Button Clicked")
        let payVC = storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        navigationController?.pushViewController(payVC, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    // Tap a Cell then Show YogaExercise
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categoryStr = ""
        let recipeRecord = recipesArray[indexPath.row]
        
        let rdVC = storyboard?.instantiateViewController(withIdentifier: "RecipeDetails") as! RecipeDetails
        rdVC.recipeObj = recipeRecord
        navigationController?.pushViewController(rdVC, animated: true)
        
    }
    
    
    
    
    // Search Button
    @IBAction func searchButt(_ sender: AnyObject) {
        showSearchBar()
    }
    
    func showSearchBar() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.searchBar.frame.origin.y = 64
            }, completion: { (finished: Bool) in
                self.searchBar.becomeFirstResponder()
        })
    }
    func hideSearchBar() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.searchBar.frame.origin.y = -60
            }, completion: { (finished: Bool) in
                self.searchBar.resignFirstResponder()
        })
    }
    
    
    // SearchBar Delegates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categoryStr = ""
        queryRecipes(searchBar.text!)
        hideSearchBar()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        hideSearchBar()
    }
    
    
    
    
    // Filter by Categories
    @IBAction func filterByCategoriesButt(_ sender: AnyObject) {
        searchBar.text = ""
        let catVC = storyboard?.instantiateViewController(withIdentifier: "Categories") as! Categories
        present(catVC, animated: true, completion: nil)
    }
    
    
    // Refresh Button
    @IBAction func refreshButt(_ sender: AnyObject) {
        searchBar.text = ""
        categoryStr = ""
        if PFUser.current() != nil { queryRecipes("") }
    }
    
    
    
    // MARK: - AdMob BANNERS
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height - 46, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        hideBanner(adMobBannerView)
    }    
    
    func pressButton(button: UIButton) {
        print("Button Clicked")
        let payVC = storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        payVC.nID = button.tag
        navigationController?.pushViewController(payVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
