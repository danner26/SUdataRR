//
//  WindowController.swift
//  SUdataRR
//
//  Created by danner on 8/29/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBAction func openDocument(sender: AnyObject?) {
        
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles      = false
        openPanel.canChooseFiles        = false
        openPanel.canChooseDirectories  = true
        print("im here")
        openPanel.beginSheetModal(for: self.window!) {
            (response) -> Void in
            guard response == NSFileHandlingPanelOKButton else {
                return;
            }
            self.contentViewController?.representedObject = openPanel.url
            print("now im here")
        }
    }
    
}
