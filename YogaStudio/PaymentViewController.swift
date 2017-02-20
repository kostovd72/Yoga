
import UIKit
import StoreKit
import Parse
import SwiftyStoreKit

enum RegisteredPurchase : String {
    case autoRenewablePurchaseAnnual = "annual"
    case autoRenewablePurchaseMonthly = "monthly"
}

class PaymentViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    var nID : Int = 0
    let AppBundleId = "com.nomind.yoga.weightloss"
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 0..<2 {
            let frame1 = CGRect(x:  (index * Int(scrView.frame.size.width)), y: 0 , width: Int(scrView.frame.width), height: Int(scrView.frame.height) )
            let button = UIButton(frame: frame1)
            button.tag = index
            button.setBackgroundImage(UIImage(named: "pay_\(index + 1).png"), for: .normal)
            button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
            self.scrView.addSubview(button)
            
            
            
            
        }
        self.scrView.delegate = self
        self.scrView.contentSize = CGSize(width: Int(scrView.frame.size.width)*2 , height: Int(scrView.frame.size.height))
        self.scrView.isPagingEnabled = true
        // Do any additional setup after loading the view.
        
        configurePageControl()
    }
    
    func configurePageControl() {
        self.pageController.numberOfPages =  2
        self.pageController.currentPage = 0
    }

    
    func pressButton(button: UIButton) {
        if button.tag == 0 {// annual
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct(AppBundleId + "." + RegisteredPurchase.autoRenewablePurchaseAnnual.rawValue, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                
                if case .success(let product) = result {
                    // Deliver content from server, then:
                    
                    
                    UserDefaults.standard.setValue(true, forKey: "premium")
                    
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
                self.showAlert(self.alertForPurchaseResult(result))
            }
            
        }else{//monthly
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct(AppBundleId + "." + RegisteredPurchase.autoRenewablePurchaseMonthly.rawValue, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                
                if case .success(let product) = result {
                    // Deliver content from server, then:
                    UserDefaults.standard.setValue(true, forKey: "premium")
                    
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
                self.showAlert(self.alertForPurchaseResult(result))
            }
            
        }
        
        //        PFPurchase.buyProduct("com.yoga.weightloss.monthly") { (error) in
        //            if error != nil{
        //                print(error)
        //                let alertController = UIAlertController(title: "Sorry", message:
        //                    "Purchase failed!", preferredStyle: UIAlertControllerStyle.alert)
        //                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        //
        //                self.present(alertController, animated: true, completion: nil)
        //            }
        //        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = Int(pageNumber)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showAlert(_ alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let product):
            print("Purchase Success: \(product.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error {
            case .failed(let error):
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle("Purchase failed", message: "Please check your Internet connection or try again later")
                }
                return alertWithTitle("Purchase failed", message: "Unknown error. Please contact support")
            case .invalidProductId(let productId):
                return alertWithTitle("Purchase failed", message: "\(productId) is not a valid product identifier")
            case .noProductIdentifier:
                return alertWithTitle("Purchase failed", message: "Product not found")
            case .paymentNotAllowed:
                return alertWithTitle("Payments not enabled", message: "You are not allowed to make payments")
            }
        }
    }
}
