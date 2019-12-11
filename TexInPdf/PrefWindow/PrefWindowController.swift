//
//  PrefWindowController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/10.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa

class PrefWindowController: NSWindowController {
    @IBOutlet weak var LatexTemplateToolbarItem: NSToolbarItem!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        collectToolBarItems()
        LatexTemplateToolbarItemClicked(self)
    }
    
    var toolbarItems: [NSToolbarItem] = [NSToolbarItem].init()
    func collectToolBarItems() {
        toolbarItems.append(LatexTemplateToolbarItem)
    }
    
    func toggleToolbarItems(_ index: Int) {
        for i in 0 ..< toolbarItems.count {
            if i == index {toolbarItems[i].isEnabled = false}
            else {toolbarItems[i].isEnabled = true}
        }
    }
    
    @IBAction func LatexTemplateToolbarItemClicked(_ sender: Any) {
        toggleToolbarItems(0)
        openLatexTemplateView()
    }
    
    func openLatexTemplateView() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Preference"), bundle: nil)
        self.contentViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("LatexTempateViewController")) as? NSViewController
    }
    
}
