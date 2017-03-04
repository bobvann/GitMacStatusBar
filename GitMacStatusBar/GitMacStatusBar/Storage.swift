//
//  Storage.swift
//  GitMacStatusBar
//
//  Created by Roberto on 15/05/16.
//  Copyright © 2016 Roberto. All rights reserved.
//

import Foundation

class Storage{
    static let preferenceDefaults = UserDefaults.standard;
    
    static let GITpathKey = "GITpath";
    
    static func getGITpath() -> String{
        if let name = preferenceDefaults.string(forKey: GITpathKey) {
            return name;
        }else{
            return "";
        }
    }
    
    
    static func issetGITpath()->Bool{
        if let _ = preferenceDefaults.string(forKey: GITpathKey) {
            return true;
        }else{
            return false;
        }
    }
    
    static func setGITpath(_ path:String){
        preferenceDefaults.set(path, forKey: GITpathKey)
    }
}
