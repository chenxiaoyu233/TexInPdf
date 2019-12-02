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
        addMarkAtSelectedPoint()
    }

}

/* MARK: - functions */

extension PDFViewController {
    func addMarkAtSelectedPoint() {
        if let curSel = PDFViewer.currentSelection {
            os_log("you have selected something")
            var hlight: [PDFAnnotation] = [PDFAnnotation].init()
            for page in curSel.pages {
                let cur = PDFAnnotation.init(bounds: curSel.bounds(for: page),
                                             forType: .square,
                                             withProperties: nil)
                hlight.append(cur)
                page.addAnnotation(cur)
            }
            undoManager?.registerUndo(withTarget: self) { target in
                target.removeMark(pages: curSel.pages, marks: hlight)
            }
        } else {
            ShowAlertMessage(messageText: "Operation Fail",
                             informativeText: "To use this function, you should select something")
        }
    }
    func removeMark(pages: [PDFPage], marks: [PDFAnnotation]) {
        for i in 0 ..< pages.count {
            pages[i].removeAnnotation(marks[i])
        }
    }
}


/* MARK: - aux tools */
extension PDFViewController {
    func ShowAlertMessage(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        return
    }
}

