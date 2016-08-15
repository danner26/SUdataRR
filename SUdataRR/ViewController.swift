//
//  ViewController.swift
//  SUdataRR
//
//  Created by danner on 8/11/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {

    @IBOutlet weak var populateHostname: NSTextField!
    @IBOutlet weak var populateIPAddr: NSTextField!
    @IBOutlet weak var populateIPAddr2: NSTextField!
    
    @IBOutlet weak var osVersion: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //hostname
        let currentHost = Host.current().localizedName ?? ""
        populateHostname.stringValue = currentHost
        
        //ip address
        let myIP = getIFAddresses()
        if (myIP.count != 0) {
            populateIPAddr.stringValue = myIP[0]
            if (myIP.count != 1) {
                populateIPAddr2.stringValue = myIP[1]
            }
        }
        
        //mac address
        
        //OS X Version
        let osVers = ProcessInfo.processInfo.operatingSystemVersion
        let osMajorVers = String(osVers.majorVersion)
        let osMinorVers = String(osVers.minorVersion)
        let osPatchVers = String(osVers.patchVersion)
        osVersion.stringValue = (osMajorVers + "." + osMinorVers + "." + osPatchVers)
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
//get IP Address of active adapters
func getIFAddresses() -> [String] {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [] }
    guard let firstAddr = ifaddr else { return [] }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        var addr = ptr.pointee.ifa_addr.pointee
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return addresses
}
