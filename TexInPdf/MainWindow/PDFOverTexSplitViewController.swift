//
//  PDFOverTexSplitViewController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/4.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit

class PDFOverTexSplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addSyncTexPanelWidthObserver()
    }

    override var representedObject: Any? {
        didSet {
            // our App is based on PDF document,
            // so we only trans the representedObject to PDF View
            splitViewItems[0].viewController.representedObject = self.representedObject
        }
    }
    
    var noteMark: PDFAnnotation? {
        didSet {
            splitViewItems[1].viewController.representedObject = self.noteMark
        }
    }
    
    var syncTexPanelWidthObserver: NSObjectProtocol?
    func addSyncTexPanelWidthObserver() {
        syncTexPanelWidthObserver =
            NotificationCenter.default.addObserver(forName: .PDFViewScaleChanged, object: nil, queue: nil) {
                notification in
                let pdfViewController = self.splitViewItems[0].viewController as! PDFViewController
                if let pdfView = pdfViewController.PDFViewer {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("syncTexPanelWidth:pdfView"),
                        object: self,
                        userInfo: ["pdfView": pdfView]
                    )
                }
            }
    }
    
}
