//
//  SubViewController.swift
//  Kurabear
//
//  Created by AYN2K on 2020/12/13.
//

import Foundation
import UIKit
 
class SubViewController: UIViewController{
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    override func viewDidLoad() {
                super.viewDidLoad()
        
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        imageView1.contentMode = UIView.ContentMode.scaleAspectFit
    }
}
