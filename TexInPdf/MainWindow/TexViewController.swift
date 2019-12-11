//
//  TexViewController.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/4.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Cocoa
import PDFKit
import OSLog

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
        showCodeView()
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
        showErrorView()
        CompileNote()
    }
    func showPDFView() {
        pdfView.isHidden = false
        codeScrollView.isHidden = true
        errorScrollView.isHidden = true
    }
    
    @IBAction func codeButtonClicked(_ sender: NSButton) {
        showCodeView()
    }
    func showCodeView() {
        codeScrollView.isHidden = false
        errorScrollView.isHidden = true
        pdfView.isHidden = true
    }
    
    @IBAction func errorButtonClicked(_ sender: NSButton) {
        showErrorView()
    }
    func showErrorView() {
        errorScrollView.isHidden = false
        codeScrollView.isHidden = true
        pdfView.isHidden = true
    }
    
    func CompileNote() {
        let name = /*NSTemporaryDirectory()*/ "/Users/chenxiaoyu/Desktop/test/" + "test"
        let fileName = name + ".tex"
        let file = URL(fileURLWithPath: fileName, isDirectory: false)
        do {try codeView.string.write(to: file, atomically: true, encoding: .utf8)}
        catch {
            errorView.string = "[Fail] can not write code to file\n"
            errorView.string += error.localizedDescription
            showErrorView()
            return
        }
        
        print(fileName)
        startCompiler(fileName)
    }
    
    var pipe: Pipe?
    func startCompiler(_ fileName: String) {
        let compiler = Process()
        var env = ProcessInfo.processInfo.environment
        let path = env["PATH"]
        env["PATH"] = "/Library/TeX/texbin/:" + (path ?? "")
        compiler.environment = env
        compiler.executableURL = URL.init(fileURLWithPath: "/Library/TeX/texbin/latexmk")
        compiler.arguments = ["-xelatex", fileName, "-output-directory=/Users/chenxiaoyu/Desktop/tex/", "-interaction=nonstopmode"]
        compiler.currentDirectoryPath = NSTemporaryDirectory()
        pipe = Pipe()
        compiler.standardError = pipe
        compiler.standardOutput = pipe
        addCompilerTerminateObserver(target: compiler)
        pipe?.fileHandleForReading.readabilityHandler = {handle in
            let data = self.pipe?.fileHandleForReading.availableData ?? Data()
            let pipeStr = String(data: data, encoding: .utf8) ?? ""
            if pipeStr != "" {
                DispatchQueue.main.sync {
                    self.errorView.string += pipeStr
                    self.errorView.scrollToEndOfDocument(nil)
                }
            }
        }
        
        self.errorView.string = ""
        do {
            try compiler.run()
        } catch {
            errorView.string = "[Fail] can not start the compiler\n"
            errorView.string += error.localizedDescription
        }
        
    }
    
    var compilerTerminateObserver: NSObjectProtocol?
    func addCompilerTerminateObserver(target: Any?) {
        compilerTerminateObserver =
            NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: nil, queue: nil){
                notification in
                if self.compilerTerminateObserver != nil { NotificationCenter.default.removeObserver(self.compilerTerminateObserver!)
                    self.compilerTerminateObserver = nil
                }
                self.errorView.string += String(data: self.pipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8) ?? ""
                self.pipe?.fileHandleForReading.readabilityHandler = nil
                self.pipe = nil
                if let pdfdata = NSData.init(contentsOfFile:  "/Users/chenxiaoyu/Desktop/tex/test.pdf") {
                    self.pdfView.document = PDFDocument.init(data: pdfdata as Data)
                    self.showPDFView()
                }
            }
    }
}
