//
//  ViewController.swift
//  SUdataRR
//
//  Created by danner on 8/11/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var populateHostname: NSTextField!
    @IBOutlet weak var populateIPAddr: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //hostname
        let currentHost = Host.current().localizedName ?? ""
        populateHostname.stringValue = currentHost
        
        //ip address
        //let myIP =
        //populateIPAddr.stringValue = IPChecker.getIP()
        
        
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
