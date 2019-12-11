//
//  MainWindowController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/4.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit

class MainWindowController: NSWindowController {
    
    var noteMark: PDFAnnotation? {
        didSet {
            if let child = self.contentViewController as? PDFOverTexSplitViewController {
                child.noteMark = self.noteMark
            }
        }
    }
    var PDFObject: Any? {
        didSet {
            self.contentViewController?.representedObject = self.PDFObject
        }
    }
        
    /// sync the windows size between two layout
    var frame: NSRect?
    
    /// remeber the currentDestination parameter in PDFView [sync parameter between two layout]
    var currentDestination: PDFDestination?
    
    /// remeber the scaleFactor parameter in PDFView [sync parameter between two layout]
    var scaleFactor: CGFloat?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        addNoteButtonObserver()
        addFetchPDFViewObserver()
        SetupSinglePDFView()
    }
    
    /// Open a stand alone PDF View [the default set up]
    func SetupSinglePDFView() {
        frame = self.window?.frame
        if self.contentViewController != nil {
            fetchPDFView()
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.contentViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PDF View")) as? NSViewController
        updateRepresentedObjectInChlid()
        self.window?.setFrame(frame!, display: true)
        pushPDFView()
    }
    
    /// Open a split view where the pdf view is over the tex view
    func SetupPDFViewOverTexView() {
        frame = self.window?.frame
        if self.contentViewController != nil {
            fetchPDFView()
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.contentViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PDFOverTexSplitViewController")) as? NSViewController
        updateRepresentedObjectInChlid()
        self.window?.setFrame(frame!, display: true)
        pushPDFView()
    }
    
    /// Register the observer for widget button click in PDF
    func addNoteButtonObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NoteButtonHitObserver(_:)),
            name: .PDFViewAnnotationHit,
            object: nil
        )
    }
    
    /// TODO: Open/Close the note content attached to the widget button in the PDF
    /// - Parameter notification: Given by the NotificationCenter
    @objc func NoteButtonHitObserver(_ notification: Notification) {
        if let note = notification.userInfo?["PDFAnnotationHit"] as? PDFAnnotation{
            if noteMark == nil {
                noteMark = note
                SetupPDFViewOverTexView()
            } else if noteMark == note {
                noteMark = nil
                SetupSinglePDFView()
            } else if noteMark != note {
                noteMark = note
            }
        }
    }
    
    /// sync the representedObject between two layout
    func updateRepresentedObjectInChlid() {
        self.contentViewController?.representedObject = self.PDFObject
        if let child = self.contentViewController as? PDFOverTexSplitViewController {
            child.noteMark = self.noteMark
        }
    }
    
    /// ask the information about PDFViewer
    func fetchPDFView() {
        NotificationCenter.default.post(
            name: NSNotification.Name.init("fetchPDFViewAsk"),
            object: self
        )
    }
    /// add the observer to listen the response of fetchPDFView
    func addFetchPDFViewObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchPDFViewObserver),
            name: NSNotification.Name.init("fetchPDFViewRsp"),
            object: nil
        )
    }
    /// record the parameter of PDFView
    /// - Parameter notification: --
    @objc func fetchPDFViewObserver(_ notification: Notification) {
        currentDestination = notification.userInfo?["currentDestination"] as? PDFDestination
        scaleFactor = notification.userInfo?["scaleFactor"] as? CGFloat
    }
    /// use parameters stored here to sync the PDFView in the child view
    func pushPDFView() {
        if currentDestination != nil && scaleFactor != nil {
            NotificationCenter.default.post(
                name: Notification.Name.init("pushPDFAsk"),
                object: self,
                userInfo: [
                    "currentDestination": currentDestination as Any,
                    "scaleFactor": scaleFactor as Any
                ]
            )
        }
    }
    
}
