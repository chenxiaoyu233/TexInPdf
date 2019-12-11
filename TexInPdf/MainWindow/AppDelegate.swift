//
//  AppDelegate.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/1.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    override init() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Preference"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PreferenceWindowController")) as! NSWindowController
        self.preferenceWindowController = windowController
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    var preferenceWindowController: NSWindowController
    @IBAction func OpenPreferenceWindow(_ sender: Any) {
        self.preferenceWindowController.showWindow(self)
    }

}

