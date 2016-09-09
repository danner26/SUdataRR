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
import AppKit

class BackupDataViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    // var dataArray = loadScripts(atPath: "/Users")
    let sizeFormatter = ByteCountFormatter()
    var directory:Directory?
    var directoryItems:[Metadata]?
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    var url = NSURL(fileURLWithPath: "/")
    
    @IBOutlet weak var test: NSTextField!
    @IBAction func backButton(_ sender: AnyObject) {
        self.dismissViewController(self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = (self)
        tableView.dataSource = (self)
        //self.representedObject = String(url)
        //directory = Directory(folderURL: url)
        
        //reloadFileList()
        print(shell(launchPath: "/bin/ls", arguments: ["/"])) //tring to use shell stuff
        
    }
    func shell(launchPath: String, arguments: [String] = []) -> (String?) { // , Int32) {
        
        let task = Task()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        task.waitUntilExit()
        return (output) //, task.terminationStatus)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            if let url = representedObject as? NSURL {
                directory = Directory(folderURL: url)
                reloadFileList()
                
            }
        }
    }
    func reloadFileList() {
        directoryItems = directory?.contentsOrderedBy(orderedBy: sortOrder, ascending: sortAscending)
        tableView.reloadData()
    }
}
extension BackupDataViewController : NSTableViewDataSource {
    private func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
}
extension BackupDataViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        // 1
        guard let item = directoryItems?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            image = item.icon
            text = item.name
            cellIdentifier = "NameCellID"
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.date.description
            cellIdentifier = "DateCellID"
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.isFolder ? "--" : sizeFormatter.stringFromByteCount(item.size)
            cellIdentifier = "SizeCellID"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
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
        } else if url.lastPathComponent == ".localized" {
            continue
        }
        urls.append(url)
    }
    return urls
}


// Start Dict here
public struct Metadata : CustomDebugStringConvertible , Equatable {
    
    let name:String
    let date:NSDate
    let size:Int64
    let icon:NSImage
    let color:NSColor
    let isFolder:Bool
    let url:NSURL
    
    init(fileURL:NSURL, name:String, date:NSDate, size:Int64, icon:NSImage, isFolder:Bool, color:NSColor ) {
        self.name  = name
        self.date = date
        self.size = size
        self.icon = icon
        self.color = color
        self.isFolder = isFolder
        url = fileURL
    }
    
    public var debugDescription: String {
        return name + " " + "Folder: \(isFolder)" + " Size: \(size)"
    }
    
}

//MARK:  Metadata  Equatable
public func ==(lhs: Metadata, rhs: Metadata) -> Bool {
    return lhs.url.isEqual(rhs.url)
}


public struct Directory  {
    
    private var files = [Metadata]()
    let url:NSURL
    
    public enum FileOrder : String {
        case Name
        case Date
        case Size
    }
    
    public init( folderURL:NSURL ) {
        url = folderURL
        let requiredAttributes = [URLResourceKey.localizedNameKey, URLResourceKey.effectiveIconKey,URLResourceKey.typeIdentifierKey,URLResourceKey.creationDateKey,URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey,URLResourceKey.isPackageKey]
        if let enumerator = FileManager.default.enumerator(at: folderURL as URL, includingPropertiesForKeys: requiredAttributes, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil) {
            
            while let url  = enumerator.nextObject() as? NSURL {
                print( "\(url )")
                
                do{
                    
                    let properties = try  url.resourceValues(forKeys: requiredAttributes)
                    files.append(Metadata(fileURL: url,
                                          name: properties[URLResourceKey.localizedNameKey] as? String ?? "",
                                          date: properties[URLResourceKey.creationDateKey] as? NSDate ?? NSDate.distantPast,
                                          size: (properties[URLResourceKey.fileSizeKey] as? NSNumber)?.int64Value ?? 0,
                                          icon: properties[URLResourceKey.effectiveIconKey] as? NSImage  ?? NSImage(),
                                          isFolder: (properties[URLResourceKey.isDirectoryKey] as? NSNumber)?.boolValue ?? false,
                                          color: NSColor()))
                }
                catch {
                    print("Error reading file attributes")
                }
            }
        }
    }
    
    
    mutating func contentsOrderedBy(orderedBy:FileOrder, ascending:Bool) -> [Metadata] {
        let sortedFiles:[Metadata]
        switch orderedBy
        {
        case .Name:
            sortedFiles = files.sorted{ return sortMetadata(lhsIsFolder: true, rhsIsFolder: true, ascending: ascending, attributeComparation:itemComparator(lhs: $0.name, rhs: $1.name, ascending:ascending)) }
        case .Size:
            sortedFiles = files.sorted{ return sortMetadata(lhsIsFolder: true, rhsIsFolder: true, ascending:ascending, attributeComparation:itemComparator(lhs: $0.size, rhs: $1.size, ascending: ascending)) }
        case .Date:
            sortedFiles = files.sorted{ return sortMetadata(lhsIsFolder: true, rhsIsFolder: true, ascending:ascending, attributeComparation:itemComparator(lhs: $0.date, rhs: $1.date, ascending:ascending)) }
        }
        return sortedFiles
    }
    
}

//MARK: - Sorting
func sortMetadata(lhsIsFolder:Bool, rhsIsFolder:Bool,  ascending:Bool , attributeComparation:Bool ) -> Bool
{
    if( lhsIsFolder && !rhsIsFolder) {
        return ascending ? true : false
    }
    else if ( !lhsIsFolder && rhsIsFolder ) {
        return ascending ? false : true
    }
    return attributeComparation
}

func itemComparator<T:Comparable>( lhs:T, rhs:T, ascending:Bool ) -> Bool {
    return ascending ? (lhs < rhs) : (lhs > rhs)
}


//MARK: NSDate Comparable Extension
extension NSDate: Comparable {
    
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs as Date) == .orderedSame {
        return true
    }
    return false
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs as Date) == .orderedAscending {
        return true
    }
    return false
}
