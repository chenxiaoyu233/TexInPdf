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
    
    var frame: NSRect?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        addNoteButtonObserver()
        SetupSinglePDFView()
    }
    
    /// Open a stand alone PDF View [the default set up]
    func SetupSinglePDFView() {
        frame = self.window?.frame
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.contentViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PDF View")) as? NSViewController
        updateRepresentedObjectInChlid()
        self.window?.setFrame(frame!, display: true)
    }
   
    func SetupPDFViewOverTexView() {
        frame = self.window?.frame
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.contentViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PDFOverTexSplitViewController")) as? NSViewController
        updateRepresentedObjectInChlid()
        self.window?.setFrame(frame!, display: true)
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
    
    func updateRepresentedObjectInChlid() {
        self.contentViewController?.representedObject = self.PDFObject
        if let child = self.contentViewController as? PDFOverTexSplitViewController {
            child.noteMark = self.noteMark
        }
    }
}
