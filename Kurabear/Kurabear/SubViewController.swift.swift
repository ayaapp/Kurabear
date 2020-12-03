//
//  SubViewController.swift.swift
//  Kurabear
//
//  Created by AYN2K on 2020/12/03.
//

import Foundation
import UIKit
 
class SubViewController: UIViewController{
 
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var selectedImage: UIImage!
    var selectedDate: String = ""
    override func viewDidLoad() {
                super.viewDidLoad()
        
        imageView.image = selectedImage
        label.text = selectedDate
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
    }
}
