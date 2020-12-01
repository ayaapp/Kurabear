//
//  ViewController.swift
//  Kurabear
//
//  Created by AYN2K on 2020/11/23.
//

import UIKit
import Photos
import CropViewController

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    var checkPermission = CheckPermission()
    var imageView = UIImageView()
    
    //画像と日付を構造体を用いてセットにする
    struct Image {
        let image: UIImage
        let date: String
    }
    
    //構造体の配列を作成
    var imageArray: [Image] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        checkPermission.checkCamera()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func album(_ sender: Any) {
        setImagePicker()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label = cell.contentView.viewWithTag(2) as! UILabel
        
        let image = imageArray[indexPath.row]
        imageView.image = image.image
        label.text = image.date
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/3
        
    }
    
    func setImagePicker(){
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
        
    }

    //アルバムのキャンセル
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil else { return }
        
        //日付
        var shootingDate: String = ""
        
        // 日時の表示形式
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/MM/dd"
        
        guard let asset = info[.phAsset] as? PHAsset else { return }
        shootingDate = formatter.string(from: asset.creationDate!)
        print(shootingDate)
        
        
        if let pickerImage = info[.editedImage] as? UIImage{
            
            picker.dismiss(animated: true, completion: nil)
            
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
            cropController.delegate = self
            cropController.customAspectRatio = CGSize(width: 100, height: 100)
            
            //pickerImageをImgeのimageに、shootingDateをImageのdateに表示する。
            let image = Image(image: pickerImage, date: shootingDate)
            imageArray.append(image)
            
            tableView.reloadData()
            
            //日付順に並べる
            imageArray = imageArray.sorted(by: {(a, b) -> Bool in
                return a.date > b.date
                
            })
        }
        
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        //CropViewControllerを初期化する。pickerImageを指定する。
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        
        cropController.delegate = self
        cropController.customAspectRatio = CGSize(width: 100, height: 100)
        
        //今回は使わないボタン等を非表示にする。
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.rotateButtonsHidden = true
        
        //cropBoxのサイズを固定する。
        cropController.cropView.cropBoxResizeEnabled = false
        //pickerを閉じたら、cropControllerを表示する。
        picker.dismiss(animated: true) {
            self.present(cropController, animated: true, completion: nil)
            
        }
        
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            setImagePicker()
            
        }
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //トリミング編集が終えたら、呼び出される。
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
        
    }
    
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        //トリミングした画像をimageViewのimageに代入する。
        self.imageView.image = image
        
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
        
    }

    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            imageArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            
        }
        
    }
    
}
