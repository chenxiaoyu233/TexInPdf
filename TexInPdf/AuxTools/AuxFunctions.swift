//
//  AuxFunctions.swift
//  TexInPdf
//
//  Created by 陈小羽 on 2019/12/11.
//  Copyright © 2019 chenxiaoyu233. All rights reserved.
//

import Foundation
import Cocoa

func NewWindowController(storyboard: String, identifier: String) -> NSWindowController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name(storyboard), bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! NSWindowController
    return windowController
}
