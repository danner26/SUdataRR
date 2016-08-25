//
//  BackupDataViewController.swift
//  SUdataRR
//
//  Created by danner on 8/24/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

// Order of how to make backup
// make folder in temp with the users username
// create reade/write dmg with hdiutil - UDRW
// Attach the volume
// copy data recursivly to the volume
// Dismount the volume

import Cocoa
import Foundation
import NetFS

class BackupDataViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

}
//use for table method.. not in use atm, maybe later down the road
func loadScripts(atPath: String) -> [NSURL] {
    var urls : [NSURL] = []
    let dirUrl = NSURL(fileURLWithPath: atPath)
    let fileManager = FileManager.default
    let enumerator:FileManager.DirectoryEnumerator? = fileManager.enumerator(at: dirUrl as URL, includingPropertiesForKeys: nil)
    while let url = enumerator?.nextObject() as! NSURL? {
        if url.lastPathComponent == ".DS_Store" {
            continue
        }
        urls.append(url)
    }
    return urls
}
