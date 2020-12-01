//
//  CheckPermission.swift
//  Kurabear
//
//  Created by AYN2K on 2020/11/23.
//

import Foundation


import Foundation
import Photos


class CheckPermission{
    
    func checkCamera(){
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status){
            
            case .authorized:
                print("authorized")
                
            case .notDetermined:
                print("notDetermined")
                
            case .restricted:
                print("restricted")
                
            case .denied:
                print("denied")
            case . limited:
                print("limited")
                
            @unknown default:
                break
            }
            
            
        }
    }
    
    
}
