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
   
    // MARK: -モードの切り替え
    enum Mode {
        case view
        case select
      }
    
    // MARK: -Properties
    var checkPermission = CheckPermission()
    var imageView = UIImageView()
    //セルを選択した場合の画像と日付
    var selectedImage: UIImage?
    var selectedDate: String = ""
    //日付
    var shootingDate: String = ""
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
     let cellIdentifier = "ItemCollectionViewCell"
     let viewImageSegueIdentifier = "viewImageSegueIdentifier"
     
    
    //画像と日付を構造体を用いてセットにする
    struct Image {
        let image: UIImage
        let date: String
        var done : Bool = false
    }

    //構造体の配列を作成
    var imageArray: [Image] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        checkPermission.checkCamera()
        setupBarButtonItems()

    }
    
    @IBAction func album(_ sender: Any) {
        setImagePicker()
    }
   
        
        var mMode: Mode = .view {
            didSet {
              switch mMode {
              case .view:
                selectBarButton.title = "Select"
                tableView.allowsMultipleSelection = false

              case .select:
                selectBarButton.title = "Cancel"
                tableView.allowsMultipleSelection = true

              }
            }
          }
        
    lazy var selectBarButton: UIBarButtonItem = {
       let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(didSelectButtonClicked(_:)))
       return barButtonItem
     }()

    
    private func setupBarButtonItems() {
            navigationItem.leftBarButtonItem = selectBarButton
          }
        
        @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
            mMode = mMode == .view ? .select : .view
          }

    
    
    // MARK: -tableViewの設定
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
        
        //チェックマークを表示する処理ーdoneがtrueだったら表示falseだったら非表示
        cell.accessoryType = image.done ? .checkmark : .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/3
        
    }
    // MARK: -セルが選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // UImage を設定
        
        switch mMode {
            case .view:
                var image = imageArray[indexPath.row]
                selectedImage = image.image
                selectedDate = image.date
                print("\(indexPath.row)番目の行が選択されました。")

                
                if selectedImage != nil {
                    // SubViewController へ遷移するために Segue を呼び出す
                    performSegue(withIdentifier: "toSubViewController",sender: nil)
                        }
            case .select:
                var image = imageArray[indexPath.row]
                
        }
        
    }
            
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            let subVC: SubViewController = (segue.destination as? SubViewController)!
    // SubViewController のselectedImgに選択された画像を設定する
            subVC.selectedImage = selectedImage
            subVC.selectedDate = selectedDate
                    }
                }
    
    // MARK: -CropViewControllerでトリミング
    func setImagePicker(){
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil else { return }
        
        
        // 日時の表示形式
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy / MM / dd"
        
        guard let asset = info[.phAsset] as? PHAsset else { return }
        shootingDate = formatter.string(from: asset.creationDate!)
        print(shootingDate)
        
        
        if let pickerImage = info[.editedImage] as? UIImage{
            
            picker.dismiss(animated: true, completion: nil)
            //CropViewControllerを初期化する。pickerImageを指定する。
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
            cropController.delegate = self
            cropController.customAspectRatio = CGSize(width: 414, height: 350)
           
        }
        
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        //CropViewControllerを初期化する。pickerImageを指定する。
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        
        cropController.delegate = self
        cropController.customAspectRatio = CGSize(width: 414, height: 350)
        
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
        imageArray.append(Image(image: image, date: shootingDate))
        imageArray = imageArray.sorted(by: {(a, b) -> Bool in
            return a.date > b.date
            
        })
        
        tableView.reloadData()
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    // MARK: -アルバムのキャンセル
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: -セルをスワイプ削除
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
