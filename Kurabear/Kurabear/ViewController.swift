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
   
    // MARK: -Properties
    var checkPermission = CheckPermission()
    var imageView = UIImageView()
    //セルを選択した場合の画像と日付
    var selectedImage: UIImage?
    var selectedDate: String = ""
    //日付
    var shootingDate: String = ""
    var selectedCell = [IndexPath]()
    
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "ItemCollectionViewCell"
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    
    
    //画像と日付を構造体を用いてセットにする
    struct Image {
        let image: UIImage
        let date: String
    }
    
    //構造体の配列を作成
    var imageArray: [Image] = [] {
        didSet {
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var album: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        checkPermission.checkCamera()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = album
        self.navigationController?.navigationBar.tintColor =  .gray

        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    
    @IBAction func album(_ sender: Any) {
        setImagePicker()
    }
    
    // MARK: -編集モードの設定
    override func setEditing(_ editing: Bool, animated: Bool) {
      
        if imageArray.count < 2 {
            let alert = UIAlertController(title: "写真を比較できません", message: "2枚以上の写真が必要です。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        //Doneを押したら画面遷移
        
        if isEditing == true,selectedCell.count == 2{
            performSegue(withIdentifier: "SubViewController", sender: nil)
        }
        
        
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing

        
        if self.tableView.isEditing == true{
            album.isEnabled = false
        }else{
            album.isEnabled = true
        }
        
    }
    
    
    
    // MARK: -2枚の選択した画像と日付を画面遷移後に表示する
    
    //Segue準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.identifier == "SubViewController"){
            let subVC = segue.destination as! SubViewController
            
        }
       
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
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/3
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("選択された行 - \(indexPath.row)")
        var image = imageArray[indexPath.row]
        selectedImage = image.image
        selectedDate = image.date
        
        print("\(indexPath.row)番目の行が選択されました。")
        
        selectedCell.append(indexPath)
        if (selectedCell.count == 3) {
            let cell = tableView.cellForRow(at: selectedCell[0])
            tableView.deselectRow(at: selectedCell[0], animated: true)
            selectedCell.removeFirst()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("選択が解除された行 - \(indexPath.row)")
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
            cropController.customAspectRatio = CGSize(width: 390, height: 250)
            
        }
        
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        //CropViewControllerを初期化する。pickerImageを指定する。
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        
        cropController.delegate = self
        cropController.customAspectRatio = CGSize(width: 390, height: 250)
        
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

