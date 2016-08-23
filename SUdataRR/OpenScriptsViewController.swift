//
//  OpenScriptsViewController.swift
//  SUdataRR
//
//  Created by danner on 8/17/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa
import NetFS

class OpenScriptsViewController: NSViewController {
    @IBOutlet weak var pathControl: NSPathCell!
    @IBOutlet weak var hdtscriptsOutlet: NSTextField!
    
    @IBOutlet weak var testme: NSTextField!
    @IBAction func HDTScripts(_ sender: AnyObject) {
        // trying to on click set link
        pathControl.url = NSURL.fileURL(withPath: "/Volumes/compserv/MacOSX_Configs/HDT/Scripts")
    }
    @IBAction func runScript(_ sender: AnyObject) {
        let url = String(pathControl.url)
        let finalURL: NSString = url.truncate(from: 16, withLengthOf: (url.characters.count - 17))!
        let task = Task()
        switch (finalURL.pathExtension) {
            case "scpt":
                //testme.stringValue = finalURL as String
                task.launchPath = "/usr/bin/osascript"
                task.arguments = [finalURL as String]
                task.launch()
                //testme.stringValue = passwd.stringValue
                //task.launchPath = "/usr/bin/sudo"
                //task.arguments = ["-S", "/usr/bin/osascript", finalURL as String]
                //task.launch()
                //task.launchPath = "bin/echo"
                //task.arguments = [passwd.stringValue, "|", "/usr/bin/sudo", "-S", "/usr/bin/osascript", (finalURL as String)]
                //task.launch()
            case "sh":
                //testme.stringValue = ".sh"
                task.launchPath = "/bin/sh"
                task.arguments = [finalURL as String]
                task.launch()
            case "py":
                //testme.stringValue = ".py"
                task.launchPath = "/usr/bin/python"
                task.arguments = [finalURL as String]
                task.launch()
            case "rb":
                //testme.stringValue = ".rb"
                task.launchPath = "/usr/bin/ruby"
                task.arguments = [finalURL as String]
                task.launch()
            case "swift":
                //testme.stringValue = ".swift"
                task.launchPath = "/usr/bin/swift"
                task.arguments = [finalURL as String]
                task.launch()
            default:
                break
        }
        
    }
    override func viewWillAppear() {
        // mount the volume before view appears
        // let username = NSUserName()
        mountShare(serverAddress: "smb://fsfiles.stockton.edu/compserv")
        pathControl.url = NSURL.fileURL(withPath: "/Volumes/compserv")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    override func viewDidDisappear() {
        // unmount the volume before view disappears
        let umount = Task()
        umount.launchPath = "/sbin/umount"
        let volPoint = String("/Volumes/Scripts")
        umount.arguments = [volPoint]
        umount.launch()
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
}

extension String {
    func truncate(from initialSpot: Int, withLengthOf endSpot: Int) -> String? {
        guard endSpot > initialSpot else { return nil }
        guard endSpot + initialSpot <= self.characters.count else { return nil }
        
        let truncated = String(self.characters.dropFirst(initialSpot))
        let lastIndex = truncated.index(truncated.startIndex, offsetBy: endSpot)
        
        return truncated.substring(to: lastIndex)
    }
}
func mountShare(serverAddress: String) {
    let serverPath = NSURL(string: serverAddress)! as CFURL
    NetFSMountURLSync(serverPath, nil, nil, nil, nil, nil, nil)
}
