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
        
        /*let rubyFileName = name + ".rb"
        let rubyFile = URL(fileURLWithPath: rubyFileName, isDirectory: false)
        do {try
            """
                system 'touch \(name + ".pdf") \(name + ".aux") \(name + ".log")'
                system 'chmod o+w \(name + ".pdf") \(name + ".aux") \(name + ".log")'
                system '/Library/TeX/texbin/latex \(fileName)'
            """.write(to: rubyFile, atomically: true, encoding: .utf8)}
        catch {
            errorView.string = "[Fail] can not write code to file\n"
            errorView.string += error.localizedDescription
            showErrorView()
            return
        }*/
        
        print(fileName)
        startCompiler(fileName)
    }
    
    func Ccommand(command: String) {
        let s = (command as NSString).utf8String
        let cs = UnsafeMutablePointer<Int8>.init(mutating: s)
        ExecuteCommand(cs)
    }

    var pipe: Pipe?
    func startCompiler(_ fileName: String) {
        let compiler = Process()
        var env = ProcessInfo.processInfo.environment
        let path = env["PATH"]
        env["PATH"] = "/Library/TeX/texbin/:" + (path ?? "")
        compiler.environment = env
        compiler.executableURL = URL.init(fileURLWithPath: "/Library/TeX/texbin/latexmk")
        compiler.arguments = ["-xelatex", fileName, "-output-directory=/Users/chenxiaoyu/Desktop/tex/"]
        compiler.currentDirectoryPath = NSTemporaryDirectory()
        pipe = Pipe()
        compiler.standardError = pipe
        compiler.standardOutput = pipe
        pipe?.fileHandleForReading.waitForDataInBackgroundAndNotify()
        addNSFileHandleDataAvailableObserver()
        addDidTerminateNotificationObserver()
        
        self.errorView.string = ""
        do {
            try compiler.run()
        } catch {
            errorView.string = "[Fail] can not start the compiler\n"
            errorView.string += error.localizedDescription
        }
        
    }
    
    var NSFileHandleDataAvailableObserver: NSObjectProtocol?
    func addNSFileHandleDataAvailableObserver() {
        NSFileHandleDataAvailableObserver =
            NotificationCenter.default.addObserver(forName:.NSFileHandleDataAvailable,object: nil, queue: nil) {
                notification in
                let data = self.pipe?.fileHandleForReading.readDataToEndOfFile() ?? Data()
                let str = String(data: data, encoding: .utf8) ?? ""
                self.errorView.string += str
            }
    }
    
    var didTerminateNotificationObserver: NSObjectProtocol?
    func addDidTerminateNotificationObserver() {
        didTerminateNotificationObserver =
            NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: nil, queue: nil){
                notification in
                if self.NSFileHandleDataAvailableObserver != nil { NotificationCenter.default.removeObserver(self.NSFileHandleDataAvailableObserver!)
                    self.NSFileHandleDataAvailableObserver = nil
                }
                if self.didTerminateNotificationObserver != nil { NotificationCenter.default.removeObserver(self.didTerminateNotificationObserver!)
                    self.didTerminateNotificationObserver = nil
                }
                self.errorView.string += String(data: self.pipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8) ?? ""
            }
    }
}
