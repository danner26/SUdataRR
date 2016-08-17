//
//  ViewController.swift
//  SUdataRR
//
//  Created by danner on 8/11/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

import Cocoa
import Foundation
import NetFS

class ViewController: NSViewController {
    // Hostname outlet
    @IBOutlet weak var populateHostname: NSTextField!
    // IP Address 1 outlet
    @IBOutlet weak var populateIPAddr: NSTextField!
    @IBOutlet weak var IPAdap1: NSTextField!
    // IP Address 2 outlet
    @IBOutlet weak var populateIPAddr2: NSTextField!
    @IBOutlet weak var IPAdap2: NSTextField!
    // MAC Adress 1 outlet
    @IBOutlet weak var populateMACAddress: NSTextField!
    @IBOutlet weak var MACAdap1: NSTextField!
    // MAC Address 2 outlet
    @IBOutlet weak var populateMACAddress2: NSTextField!
    @IBOutlet weak var MACAdap2: NSTextField!
    // OS Version outlet
    @IBOutlet weak var osVersion: NSTextField!
    // Buttons
    @IBAction func refresh(_ sender: AnyObject) {
        viewDidLoad()
    }
    @IBAction func EditLoginConfig(_ sender: AnyObject) {
        let username = NSUserName()
        let task = Task()
        task.launchPath = "/bin/mkdir"
        let volPoint = String("/Volumes/" + username)
        task.arguments = [volPoint]
        task.launch()
        let myTask = Task()
        myTask.launchPath = "/sbin/mount"
        let mountPoint = String("//fsfiles.stockton.edu/home/" + username)
        myTask.arguments = ["-t", "smbfs", mountPoint, volPoint]
        myTask.launch()
        let editTask = Task();
        editTask.launchPath = "/usr/bin/open"
        let filePoint = String(volPoint + "/LoginConfig.xml")
        editTask.arguments = ["-a", "/Applications/TextEdit.app", filePoint]
        editTask.launch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //hostname
        let currentHost = Host.current().localizedName ?? ""
        populateHostname.stringValue = currentHost
        
        //get adapters - includes IP, Adapter Name, and MAC Address
        let myInterfaces = getInterfaces()
        //ip address
        if (myInterfaces.count != 0) {
            populateIPAddr.stringValue = myInterfaces[0].addr
            IPAdap1.stringValue = myInterfaces[0].name
            if (myInterfaces.count != 1) {
                if (myInterfaces[0].addr != myInterfaces[1].addr) {
                    populateIPAddr2.stringValue = myInterfaces[1].addr
                    IPAdap2.stringValue = myInterfaces[1].name
                }
            } else {
                populateIPAddr2.stringValue = ""
                IPAdap2.stringValue = ""
            }
        }
        
        //mac address
        if (myInterfaces.count != 0) {
            populateMACAddress.stringValue = myInterfaces[0].mac
            MACAdap1.stringValue = myInterfaces[0].name
            if (myInterfaces.count != 1) {
                if (myInterfaces[0].mac != myInterfaces[1].mac) {
                    populateMACAddress2.stringValue = myInterfaces[1].mac
                    MACAdap2.stringValue = myInterfaces[1].name
                }
            } else {
                populateMACAddress2.stringValue = ""
                MACAdap2.stringValue = ""
            }
        }
        
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

// gets the adapter name, ip address, and mac address
func getInterfaces() -> [(name : String, addr: String, mac : String)] {
    
    var addresses = [(name : String, addr: String, mac : String)]()
    var nameToMac = [ String: String ]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [] }
    guard let firstAddr = ifaddr else { return [] }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        if let addr = ptr.pointee.ifa_addr {
            let name = String(cString: ptr.pointee.ifa_name)
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                switch Int32(addr.pointee.sa_family) {
                case AF_LINK:
                    // Get MAC address from sockaddr_dl structure and store in nameToMac dictionary:
                    let dl = UnsafePointer<sockaddr_dl>(addr)
                    let lladdr = UnsafeBufferPointer(start: UnsafePointer<Int8>(dl) + 8 + Int(dl.pointee.sdl_nlen),
                                                     count: Int(dl.pointee.sdl_alen))
                    if lladdr.count == 6 {
                        nameToMac[name] = lladdr.map { String(format:"%02hhx", $0)}.joined(separator: ":")
                    }
                case AF_INET:
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append( (name: name, addr: address, mac : "") )
                    }
                default:
                    break
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    
    // Now add the mac address to the tuples:
    for (i, addr) in addresses.enumerated() {
        if let mac = nameToMac[addr.name] {
            addresses[i] = (name: addr.name, addr: addr.addr, mac : mac)
        }
    }
    
    return addresses
}
