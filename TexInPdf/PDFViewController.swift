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
        addFetchPDFViewObserver()
        addPushPDFViewObserver()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            PDFViewer.document = self.representedObject as? PDFDocument
            for child in self.children {
                child.representedObject = self.representedObject
            }
        }
    }
}

extension PDFViewController{
    
    /// Action for menu item "Add Note", add a interactable note mark in the selected place
    /// - Parameter sender: from menu item "Add Note"
    @IBAction func AddNoteMenuItemSelected(_ sender: Any) {
        addMarkAtSelectedPoint(forType: .widget) { mark in
            mark.widgetFieldType = .button
            mark.widgetControlType = .pushButtonControl
            mark.backgroundColor = .init(calibratedRed: 1.0, green: 0.5, blue: 1.0, alpha: 0.2)
            mark.color = .init(white: 1, alpha: 0)
            mark.setValue("test message", forAnnotationKey: .textLabel)
        }
    }
    
  
}

/* MARK: - functions */
extension PDFViewController {
    
    /// Add a mark at the selected point in the pdf document
    /// - Parameter forType: the annotation type you want
    /// - Parameter modifier: customize your annotation in this closure
    func addMarkAtSelectedPoint(forType: PDFAnnotationSubtype, modifier: (inout PDFAnnotation) -> Void = {annotation in}) {
        if let curSel = PDFViewer.currentSelection {
            var hlight: [PDFAnnotation] = [PDFAnnotation].init()
            for page in curSel.pages {
                var cur = PDFAnnotation.init(bounds: curSel.bounds(for: page),
                                             forType: forType,
                                             withProperties: nil)
                modifier(&cur)
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
    
    /// Show a short alert message to the user in a popup window
    /// - Parameter messageText: the main reason of the alert
    /// - Parameter informativeText: some hint sentences for user
    func ShowAlertMessage(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

/* MARK: - sync PDFViewer */
extension PDFViewController {
    func addFetchPDFViewObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchPDFViewObserver),
            name: NSNotification.Name.init("fetchPDFViewAsk"),
            object: nil
        )
    }
    @objc func fetchPDFViewObserver(_ notification: Notification) {
        NotificationCenter.default.post(
            name: NSNotification.Name.init("fetchPDFViewRsp"),
            object: self,
            userInfo: ["currentDestination": PDFViewer.currentDestination as Any,
                       "scaleFactor": PDFViewer.scaleFactor as Any]
        )
    }
    func addPushPDFViewObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pushPDFViewObserver),
            name: NSNotification.Name.init("pushPDFAsk"),
            object: nil
        )
    }
    @objc func pushPDFViewObserver(_ notification: Notification) {
        if let scaleFactor = notification.userInfo?["scaleFactor"] as? CGFloat {
            PDFViewer.scaleFactor = scaleFactor
        }
        if let currentDestination = notification.userInfo?["currentDestination"] as? PDFDestination {
            PDFViewer.go(to: currentDestination)
        }
    }
}
