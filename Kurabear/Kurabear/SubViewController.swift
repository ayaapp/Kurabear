//
//  SubViewController.swift
//  Kurabear
//
//  Created by AYN2K on 2020/12/13.
//

import Foundation
import UIKit
 


class SubViewController: UIViewController{
    
    var image1 = UIImage()
    var image2 = UIImage()
    var date1 = String()
    var date2 = String()
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView1.image = image1
        imageView2.image = image2
        label1.text = date1
        label2.text = date2
        
        
    }
}
