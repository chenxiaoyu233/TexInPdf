//
//  TexResizePanelController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/7.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit

class TexResizePanelController: NSSplitViewController {
    @IBOutlet weak var resizePanelLeft: NSSplitViewItem!
    @IBOutlet weak var resizePanelRight: NSSplitViewItem!
    @IBOutlet weak var texviewItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addSyncTexPanelWidthObserver()
    }
    
    override var representedObject: Any? {
        didSet {
            for child in children {
                child.representedObject = self.representedObject
            }
        }
    }
    
    var syncTexPanelWidthObserver: NSObjectProtocol?
    func addSyncTexPanelWidthObserver() {
        syncTexPanelWidthObserver =
            NotificationCenter.default.addObserver(forName: NSNotification.Name("syncTexPanelWidth:pdfView"), object: nil, queue: nil) {
                notification in
                if let pdfView = notification.userInfo?["pdfView"] as! PDFView? {
                    let texWidth = pdfView.rowSize(for: pdfView.currentPage!).width - 4
                    let totalWidth = pdfView.frame.size.width
                    self.splitView.setPosition((totalWidth - texWidth)/2.0 - 30, ofDividerAt: 0)
                    self.splitView.setPosition((totalWidth - texWidth)/2.0 + texWidth, ofDividerAt: 1)
                }
            }
    }
    
}
