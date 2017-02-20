

import Foundation
import UIKit
import Parse




let APP_NAME = "Yoga for you - weight loss" // Your App Name

let ADMOB_BANNER_UNIT_ID = "ca-app-pub-3940256099942544/6300978111" // Your AdMob ID

let ONESIGNAL_APP_ID = "c1924d23-8008-42e3-b4f7-f8428c5e0e34" // Your OneSignal ID for Push Notifications

// Yor Details for About Us
let ADMIN_EMAIL_ADDRESS = "sayooj.valsan@gmail.com"
let WEBSITE_URL = "http://www.apple.com"
let FACEBOOK_URL = "https://www.facebook.com/username"
let TWITTER_URL = "https://twitter.com/username"


// Your Parse Keys
let PARSE_APP_KEY = "YkIUiiundL4YxYHz89pwu6gTnC3dU9YHDRZapvx1"
let PARSE_CLIENT_KEY = "pi4pLzv5yWNHBkkml1VwHWjDJQYM034MNxKpoaVG"




// Yoga Catgories
let categoriesArray =  [
    "All Exercises",
    "Beginers Essentials",
    "Intermediate Essentials",
    "Advanced Essentials",
]




// Custom violet color
let yellow = UIColor(red: 156/255.0, green: 157/255.0, blue: 245/255.0, alpha: 1.0)



// HUD VIEW
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
extension UIViewController {
    func showHUD(_ message:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        hudView.alpha = 0.7
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 70, width: 100, height: 30)
        label.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        label.text = message
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}








// Vars for Parse
let defaults = UserDefaults.standard
var justSignedUp = false


let USER_CLASS_NAME = "_User"
let USER_FULLNAME = "fullName"
let USER_AVATAR = "avatar"
let USER_USERNAME = "username"
let USER_PASSWORD = "password"
let USER_EMAIL = "email"

let EXERCISES_CLASS_NAME = "Exercises"
let EXERCISES_TITLE = "title"     // String
let EXERCISES_IMAGE1 = "image1"   // File
let EXERCISES_IMAGE2 = "image2"   // File
let EXERCISES_IMAGE3 = "image3"   // File
let EXERCISES_TITLE_LOWERCASE = "titleLowercase" // String
let EXERCISES_CATEGORY = "category"   // String
let EXERCISES_ABOUT = "aboutExercises"   // String
let EXERCISES_ABILITY = "ability"   // String
let EXERCISES_TIME = "time"     // String
let EXERCISES_POSES = "poses"   // String
let EXERCISES_INTENSITY = "intensity"   // String
let EXERCISES_FOCUS = "focus"  // String
let EXERCISES_YOUTUBE = "youtube"     // String
let EXERCISES_VIDEO_TITLE = "videoTitle"  // String
let EXERCISES_VIDEO = "video"   // File
let EXERCISES_VIDEO_PREVIEW = "video_preview"  // File
let EXERCISES_STEPS = "steps" // String

let FAV_CLASS_NAME = "Favorites"
let FAV_FAVORITED_BY = "favoritedBy"
let FAV_RECIPE_POINTER = "recipePointer"

//let Community_Categories=

public func timeAgoSince(_ date: Date) -> String {
    
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "\(year) years ago"
    }
    
    if let year = components.year, year >= 1 {
        return "Last year"
    }
    
    if let month = components.month, month >= 2 {
        return "\(month) months ago"
    }
    
    if let month = components.month, month >= 1 {
        return "Last month"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "\(week) weeks ago"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "Last week"
    }
    
    if let day = components.day, day >= 2 {
        return "\(day) days ago"
    }
    
    if let day = components.day, day >= 1 {
        return "Yesterday"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "\(hour) hours ago"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "An hour ago"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "\(minute) minutes ago"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "A minute ago"
    }
    
    if let second = components.second, second >= 3 {
        return "\(second) seconds ago"
    }
    
    return "Just now"
    
}


