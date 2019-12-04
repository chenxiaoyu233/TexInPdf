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
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        willSet {
            if let note = self.representedObject as? PDFAnnotation {
                note.setValue(textView.string, forAnnotationKey: .textLabel)
            }
        }
        didSet{
            if let note = self.representedObject as? PDFAnnotation {
                textView.string = note.value(forAnnotationKey: .textLabel) as? String ?? ""
            }
        }
    }
}
