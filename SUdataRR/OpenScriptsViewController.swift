//
//  OpenScriptsViewController.swift
//  SUdataRR
//
//  Created by danner on 8/17/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa

class OpenScriptsViewController: NSViewController {
    
    @IBOutlet weak var myTable: NSScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loadScripts()
    }
    func loadScripts() {
        do {
            //let files = try FileManager.defaultManager().contentsOfDirectoryPath("/Users/danner/Desktop")
        }
    }
}
