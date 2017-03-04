//
//  AppDelegate.swift
//  GitMacStatusBar
//
//  Created by Roberto on 15/05/16.
//  Copyright © 2016 Roberto. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //OUTLETS
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var gitDirectoryMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    //DATA
    var gitNames : [String] = []
    var gitDirectories : [String] = []
    var mainPATH = "";
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let icon = NSImage(named: "StatusIcon")
        icon?.isTemplate = false // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        
        statusItem.menu = statusMenu
        
        statusMenu.autoenablesItems=false
        
        if(Storage.issetGITpath()){
            self.setGITPath()
        }else{
            statusMenu.item(at: 0)?.isEnabled = false
            self.gitDirectoryMenuItem.title = "Choose GIT Folder"
        }
        
    }
    
    @IBAction func quitMenuClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func reloadMenuClicked(_ sender: NSMenuItem) {
        self.reloadItems()
    }
    
    @IBAction func gitDirectoryMenuClicked(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if let url = openPanel.url{
                        Storage.setGITpath(url.path)
                }
                
                
                self.setGITPath();
            }
        }
    }
    
    func setGITPath(){
        self.mainPATH = Storage.getGITpath();
        self.statusMenu.item(at: 0)?.isEnabled = true
        self.gitDirectoryMenuItem.title = self.mainPATH
        self.reloadItems()
    }
    
    func reloadItems(){
        let n = statusMenu.items.count
        
        //skipping "header" and preferences
        if(n>6){
            for _ in 6...n-1{
                statusMenu.removeItem(at: 3)
            }
        }
        
        self.createGITArray()
        
        if(self.gitDirectories.count>0){
            for i in 0...self.gitDirectories.count-1{
                let path = self.gitDirectories[i]
                let par =  "(cd " + path + " && (pwd; git status --porcelain | grep -v 'DS_Store')) 2>/dev/null "
                
                let (resData,exitCode) = self.shell(launchPath: "/bin/bash", args: ["-c", par])
                
                self.shellCompleted(result: resData!, exitCode: exitCode)
                
            }
        }
    }

    
    
    func createGITArray(){
        self.gitNames=[]
        self.gitDirectories=[]
        
        let dirURL = URL(fileURLWithPath: self.mainPATH, isDirectory: true)
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(
            at: dirURL,
            includingPropertiesForKeys: keys,
            options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants ,
                FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants ,
                FileManager.DirectoryEnumerationOptions.skipsHiddenFiles],
            errorHandler: {(url, error) -> Bool in
                return true
            }
        )
        while let element = enumerator?.nextObject() as? URL {
            var getter: AnyObject?
            do{
                try (element as NSURL).getResourceValue(&getter, forKey: URLResourceKey.isDirectoryKey)
                let isDirectory = getter! as! Bool
                try (element as NSURL).getResourceValue(&getter, forKey: URLResourceKey.localizedNameKey)
                let itemName = getter! as! String
                if isDirectory {
                    self.gitNames.append(itemName)
                    self.gitDirectories.append(self.mainPATH + "/" + itemName)
                    
                    //do something with element here.
                }
            }catch{
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func shell(launchPath: String, args: [String] = []) -> (String? , Int32) {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        task.waitUntilExit()
        
        return (output, task.terminationStatus)
    }
    
    func shellCompleted(result: String, exitCode: Int32){
        let x = result.components(separatedBy: "\n");
        
        let elName = x[0]
        
        
        //old way, just check if there is any row
        //let isClean = x.count<3 && x[1]==""
        
        //this works because grep exit 0 when it finds rows, exit 1 when no row is found
        //no round is found = no pending file
        
        let isClean = (exitCode==1)
        
        self.addSingleElementToMenuBar(elName, clean: isClean)
    }
    
    
    
    func addSingleElementToMenuBar(_ path:String, clean: Bool){
        
        let i = self.gitDirectories.index(of: path)
        let name = self.gitNames[i!]
        
        let menuItem = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        
        if(clean){
             menuItem.image = NSImage(named: "GitIconGreen")
        }else{
             menuItem.image = NSImage(named: "GitIconRed")
        }
        
        statusMenu.addItem(menuItem)
        statusMenu.update()
        
    }
    
}

