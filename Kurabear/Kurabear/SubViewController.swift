//
//  SubViewController.swift
//  Kurabear
//
//  Created by AYN2K on 2020/12/13.
//

import Foundation
import UIKit
 


class SubViewController: UIViewController{
    
    var image = UIImage()
    var date = String()
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView1.image = image
        imageView2.image = image
        label1.text = date
        label2.text = date
        
        
    }
}
