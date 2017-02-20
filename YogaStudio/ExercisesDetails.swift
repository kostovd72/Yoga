

import UIKit
import Parse
import AudioToolbox
import MessageUI
import AVFoundation
import AVKit
import UICircularProgressRing

class RecipeDetails: UIViewController, UIScrollViewDelegate, UICircularProgressRingDelegate, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate
{
  
    
    // Views
    @IBOutlet weak var sliderScrollView: UIScrollView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var recipeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var aboutReceipeLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var cookingLabel: UILabel!
    @IBOutlet weak var portionsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var glutenFreeLabel: UILabel!
    @IBOutlet var timingLabels: [UILabel]!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var preparationTxt: UITextView!
    @IBOutlet weak var favOutlet: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressView: UICircularProgressRingView!
    @IBOutlet weak var previewImage: UIImageView!
    
    
    var downloadTask: URLSessionDownloadTask!

    var backgroundSession: URLSession!
    //@IBOutlet weak var ingredientsTxt: UITextView!
    //@IBOutlet weak var addToShoppingOutlet: UIButton!
    //@IBOutlet weak var openYouTubeOutlet: UIButton!
    //@IBOutlet weak var videoWebView: UIWebView!

    // Vars
    var recipeObj = PFObject(className: EXERCISES_CLASS_NAME)
    var ingredientsArray = [String]()
    var favoritesArray = [PFObject]()
    var videoURL: URL? // URL where file saved on local
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //progressView.delegate = self
        progressView.fontColor = UIColor.gray
        
        self.edgesForExtendedLayout = UIRectEdge()
    
        // Setup slider ScrollView
        image1.frame.origin.x = 0
        image2.frame.origin.x = sliderScrollView.frame.size.width
        image3.frame.origin.x = sliderScrollView.frame.size.width*2
        
        // Back BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.adjustsImageWhenHighlighted = false
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.addTarget(self, action: #selector(backButton(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        backButt.setTitle("BACK", for: UIControlState.normal)
        backButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        backButt.setTitleColor(UIColor.black, for:UIControlState.normal)
        
        // SHARE BarButton Item
        let shareButt = UIButton(type: UIButtonType.custom)
        shareButt.adjustsImageWhenHighlighted = false
        shareButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        shareButt.addTarget(self, action: #selector(shareButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButt)
        shareButt.setTitle("SHARE", for: UIControlState.normal)
        shareButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        shareButt.setTitleColor(UIColor.black, for:UIControlState.normal)
        
        // Show YogaExercise details
        showRecipeDetails()
        
        // Init ad banners
        //initAdMobBanner()
        
        
        // Check if the video file already exists
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let fileName = recipeObj[EXERCISES_VIDEO_TITLE] as! String + ".mp4"
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/" + fileName))
        self.videoURL = destinationURLForFile
        
        //Here you can see the url where file saved
        print("******videoFile url on local******")
       
       
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            print("******file already exists")
            playButton.isHidden = false
            downloadButton.isHidden = true
            progressView.isHidden = true
           
        }
        else{
            print("******file doesn't exists")
            playButton.isHidden = true
            downloadButton.isHidden = false
            progressView.isHidden = true
        }



        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        downloadTask?.cancel()
        backgroundSession?.invalidateAndCancel()
    }
    
    // Download Video file from parse server
    @IBAction func downloadClicked(_ sender: UIButton) {
        
        downloadButton.isHidden = true
        progressView.isHidden = false

        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)

        
        
        let url = URL(string: recipeObj["videoFile"] as! String)!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
   
    // The UICircularProgressRingDelegate method called when download progress finished
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        
       // downloadButton.isHidden = true
        //progressView.isHidden = true
        //playButton.isHidden = false
        //self.playVideo()
    }
    
    // Play Video on local
    @IBAction func playClick(_ sender: UIButton) {
        
        playVideo()
        
    }
    
    func playVideo(){
        
        if (videoURL == nil){
            let alert = UIAlertController(title: APP_NAME,
                                          message: "There is no video existing in your phone",
                                          preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                return
            })
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        }
        let player = AVPlayer(url: videoURL!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
        
    }
    
    // Show YogaExercise Details
    func showRecipeDetails() {
        
        // Get images
        let imageFile1 = recipeObj[EXERCISES_IMAGE1] as? PFFile
        imageFile1?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image1.image = UIImage(data:imageData)
                    self.pageControl.numberOfPages = 1
                }}})
        
        let imageFile2 = recipeObj[EXERCISES_IMAGE2] as? PFFile
        imageFile2?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image2.image = UIImage(data:imageData)
                    self.pageControl.numberOfPages = 2
                }}})
        
        
        let imageFile3 = recipeObj[EXERCISES_IMAGE3] as? PFFile
        imageFile3?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image3.image = UIImage(data:imageData)
                    self.pageControl.numberOfPages = 3
                }}})
        
        let previewImage = recipeObj[EXERCISES_VIDEO_PREVIEW] as? PFFile
        previewImage?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.previewImage.image = UIImage(data:imageData)
                    
                }}})
        
        sliderScrollView.contentSize = CGSize(width: sliderScrollView.frame.size.width * CGFloat(pageControl.numberOfPages), height: sliderScrollView.frame.size.height)
        
        
        
        // Show YogaExercise Details
        titleLabel.text = "\(recipeObj[EXERCISES_TITLE]!)"
        categoryLabel.text = "\(recipeObj[EXERCISES_CATEGORY]!)"
        
        aboutReceipeLabel.text = "\(recipeObj[EXERCISES_ABOUT]!)"
        
        //Line
        let paragraphStyle02 = NSMutableParagraphStyle()
        let lineHeight02: CGFloat = 18.0
        paragraphStyle02.lineHeightMultiple = lineHeight02
        paragraphStyle02.maximumLineHeight = lineHeight02
        paragraphStyle02.minimumLineHeight = lineHeight02
        let ats02 = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14.0)!, NSParagraphStyleAttributeName: paragraphStyle02]
        aboutReceipeLabel.attributedText = NSAttributedString(string: "\(recipeObj[EXERCISES_ABOUT]!)", attributes: ats02)
        
        difficultyLabel.text = "\(recipeObj[EXERCISES_ABILITY]!)"
        
        cookingLabel.text = "\(recipeObj[EXERCISES_TIME]!)"
        cookingLabel.layer.cornerRadius = 8
        cookingLabel.layer.borderColor = UIColor.white.cgColor
        cookingLabel.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.95).cgColor
        
        portionsLabel.text = "\(recipeObj[EXERCISES_POSES]!)"
        portionsLabel.layer.cornerRadius = 8
        portionsLabel.layer.borderColor = UIColor.white.cgColor
        portionsLabel.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.95).cgColor
        
        caloriesLabel.text = "\(recipeObj[EXERCISES_INTENSITY]!)"
        caloriesLabel.layer.cornerRadius = 8
        caloriesLabel.layer.borderColor = UIColor.white.cgColor
        caloriesLabel.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.95).cgColor
        
        glutenFreeLabel.text = "\(recipeObj[EXERCISES_FOCUS]!)"
        glutenFreeLabel.layer.cornerRadius = 8
        glutenFreeLabel.layer.borderColor = UIColor.white.cgColor
        glutenFreeLabel.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.95).cgColor
        
        if recipeObj[EXERCISES_VIDEO_TITLE] != nil { videoTitleLabel.text = "\(recipeObj[EXERCISES_VIDEO_TITLE]!)"
        } else { videoTitleLabel.text = "No video Available" }
        
        
        
        // Line Spacing - 01
        let paragraphStyle01 = NSMutableParagraphStyle()
        let lineHeight01: CGFloat = 18.0
        paragraphStyle01.lineHeightMultiple = lineHeight01
        paragraphStyle01.maximumLineHeight = lineHeight01
        paragraphStyle01.minimumLineHeight = lineHeight01
        _ = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14.0)!, NSParagraphStyleAttributeName: paragraphStyle01]
        
        
        // Get Steps
        preparationTxt.text = "\(recipeObj[EXERCISES_STEPS]!)"
        preparationTxt.sizeToFit()
        preparationTxt.frame.size.height = preparationTxt.frame.size.height + 400
        
        
        // Line Spacing - 02
        let paragraphStyle = NSMutableParagraphStyle()
        let lineHeight: CGFloat = 18.5
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.minimumLineHeight = lineHeight
        let ats = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14.0)!, NSParagraphStyleAttributeName: paragraphStyle]
        preparationTxt.attributedText = NSAttributedString(string: "\(recipeObj[EXERCISES_STEPS]!)", attributes: ats)
        
        
        // ScrollView content size
        self.recipeView.frame.size.height = self.preparationTxt.frame.size.height + self.preparationTxt.frame.origin.y + self.recipeView.frame.origin.y - 150
        self.containerScrollView.contentSize = CGSize(width: self.containerScrollView.frame.size.width, height: self.recipeView.frame.size.height + self.recipeView.frame.origin.y)
        
    }
    
    
    // ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = sliderScrollView.frame.size.width
        let page = Int(floor((sliderScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
        pageControl.currentPage = page
    }
    
    

    
    // Open Youtube Button
    @IBAction func openYouTubeButt(_ sender: AnyObject) {
        let youtubeLink = "\(recipeObj[EXERCISES_YOUTUBE]!)"
        let MY_URL = URL(string: youtubeLink)
        UIApplication.shared.openURL(MY_URL!)
    }
    

    
    
    // Favorite YogaExercise Button
    @IBAction func favoriteButt(_ sender: AnyObject) {
        // USER IS LOGGED IN
        if PFUser.current() != nil {
            
            let query = PFQuery(className: FAV_CLASS_NAME)
            query.whereKey(FAV_FAVORITED_BY, equalTo: PFUser.current()!)
            query.whereKey(FAV_RECIPE_POINTER, equalTo: recipeObj)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    self.favoritesArray = objects!
                    print("FAV ARRAY: \(self.favoritesArray)")
                    
                    
                    var favClass = PFObject(className: FAV_CLASS_NAME)
                    
                    // Favorite YogaExercise
                    if self.favoritesArray.count == 0 {
                        favClass[FAV_FAVORITED_BY] = PFUser.current()!
                        favClass[FAV_RECIPE_POINTER] = self.recipeObj
                        
                        favClass.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert("Added this exercise to your Favorites")
                                self.favOutlet.setBackgroundImage(UIImage(named: "favedButt"), for: UIControlState())
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                            }
                        })
                        
                        
                        //  Delete YogaExercise
                    } else if self.favoritesArray.count > 0 {
                        favClass = self.favoritesArray[0]
                        favClass.deleteInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert("Removed this exercise from your Favorites")
                                self.favOutlet.setBackgroundImage(UIImage(named: "favButt"), for: UIControlState())
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                            }
                        })
                    }
                    
                    // error
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
            
            
            
            
            // If User is not Logged or Register
        } else {
            let alert = UIAlertController(title: APP_NAME,
                                          message: "You must Login or Signup to favorite a YogaExercise",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                self.present(loginVC, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
            
            alert.addAction(ok); alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    
    // Sare Button
    func shareButton(_ sender:UIButton) {
        let messageStr  = "I love this YogaExercise: \(recipeObj[EXERCISES_TITLE]!), found on #\(APP_NAME)"
        let image = image1.image
        
        let shareItems = [messageStr, image!] as [Any]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.present(from: CGRect.zero, in: view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        } else {
            // iPhone
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Back Button
    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    
    
//    // MARK: - AdMob BANNERS
//    func initAdMobBanner() {
//        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
//        adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
//        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
//        adMobBannerView.rootViewController = self
//        adMobBannerView.delegate = self
//        view.addSubview(adMobBannerView)
//        
//        let request = GADRequest()
//        adMobBannerView.load(request)
//    }
    
//    // Hide the banner
//    func hideBanner(_ banner: UIView) {
//        UIView.beginAnimations("hideBanner", context: nil)
//        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
//        UIView.commitAnimations()
//        banner.isHidden = true
//    }
    
//    // Show the banner
//    func showBanner(_ banner: UIView) {
//        UIView.beginAnimations("showBanner", context: nil)
//        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
//        UIView.commitAnimations()
//        banner.isHidden = false
//    }
//    
  
    
    @available(iOS 7.0, *)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = self.videoURL!
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
           // showFileWithPath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
               // showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }

        
    }
    
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
       // progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
      //  print(CGFloat(totalBytesWritten))

     //   print(CGFloat(totalBytesExpectedToWrite))

        var val = CGFloat(Int((Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)) * (100.00)))
        print(val)
        self.progressView.setProgress(value: val, animationDuration:
            0, completion: nil)

    }
    

    
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
       self.progressView.setProgress(value: 0, animationDuration:
            2, completion: nil)

        
       // progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
             downloadButton.isHidden = true
            progressView.isHidden = true
            playButton.isHidden = false
            
           // playVideo()

        }
    }
  
    
    
    


    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
