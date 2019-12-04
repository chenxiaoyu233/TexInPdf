//
//  TexViewController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/4.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit

class TexViewController: NSViewController {
    @IBOutlet weak var codeScrollView: NSScrollView!
    @IBOutlet weak var errorScrollView: NSScrollView!
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet var codeView: NSTextView!
    @IBOutlet var errorView: NSTextView!
    
    @IBOutlet weak var compileButton: NSButton!
    @IBOutlet weak var codeButton: NSButton!
    @IBOutlet weak var errorButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setFont()
    }
    
    func setFont() {
        codeView.font = NSFont.init(name: "Monaco", size: 14) ?? NSFont.systemFont(ofSize: 14)
        errorView.font = codeView.font
    }
    
    override var representedObject: Any? {
        willSet {
            if let note = self.representedObject as? PDFAnnotation {
                note.setValue(codeView.string, forAnnotationKey: .textLabel)
            }
        }
        didSet{
            if let note = self.representedObject as? PDFAnnotation {
                codeView.string = note.value(forAnnotationKey: .textLabel) as? String ?? ""
            }
        }
    }
    
    @IBAction func compileButtonClicked(_ sender: NSButton) {
        pdfView.isHidden = false
        codeScrollView.isHidden = true
        errorScrollView.isHidden = true
    }
    
    @IBAction func codeButtonClicked(_ sender: NSButton) {
        codeScrollView.isHidden = false
        errorScrollView.isHidden = true
        pdfView.isHidden = true
    }
    
    @IBAction func errorButtonClicked(_ sender: NSButton) {
        errorScrollView.isHidden = false
        codeScrollView.isHidden = true
        pdfView.isHidden = true
    }
}
