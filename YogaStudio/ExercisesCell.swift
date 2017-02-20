

import UIKit

class RecipesCell: UICollectionViewCell {
    
    // Views
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var favOutlet: UIButton!
    @IBOutlet weak var watermark: UIImageView!
    @IBOutlet weak var cookingLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    var isPurchased = Bool()
}
