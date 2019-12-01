//
//  ViewController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/1.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit
import OSLog

class PDFViewController: NSViewController {
    @IBOutlet weak var PDFViewer: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func AddNoteMenuItemSelected(_ sender: Any) {
        if let curSel = PDFViewer.currentSelection {
            os_log("you have selected something")
        } else {
            let alert = NSAlert()
            alert.messageText = "Operation Fail"
            alert.informativeText = "To use this function, you should select something"
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
    }

}

