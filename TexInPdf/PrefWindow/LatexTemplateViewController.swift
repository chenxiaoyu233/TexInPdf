//
//  LatexTemplateViewController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/11.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa

class LatexTemplateViewController: NSViewController {

    @IBOutlet var LatexHeaderTextView: NSTextView!
    @IBOutlet var LatexFooterTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        reloadLatexTemplate()
    }
    
    @IBAction func ApplyButtonClicked(_ sender: Any) {
        saveLatexTemplate()
    }
    
    func saveLatexTemplate() {
        UserDefaults.standard.set(LatexHeaderTextView.string, forKey: "LatexHeaderTextView.string")
        UserDefaults.standard.set(LatexFooterTextView.string, forKey: "LatexFooterTextView.string")
    }
    
    func reloadLatexTemplate() {
        LatexHeaderTextView.string = UserDefaults.standard.value(forKey: "LatexHeaderTextView.string") as? String ?? ""
        LatexFooterTextView.string = UserDefaults.standard.value(forKey: "LatexFooterTextView.string") as? String ?? ""
    }
}
