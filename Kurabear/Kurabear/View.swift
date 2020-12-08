//
//  View.swift
//  Kurabear
//
//  Created by AYN2K on 2020/12/09.
//

import UIKit

class View: UITableViewCell {

    
    @IBOutlet weak var highlightIndicator: UIView!
    
    @IBOutlet weak var selectIndicator: UIImageView!
    
    override var isHighlighted: Bool {
      didSet {
        highlightIndicator.isHidden = !isHighlighted
      }
    }
    
    override var isSelected: Bool {
      didSet {
        highlightIndicator.isHidden = !isSelected
        selectIndicator.isHidden = !isSelected
      }
    }
    override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
      }

  }
  
