//
//  ViewController.swift
//  headphonesStatus
//
//  Created by julien@macmini on 23/09/2019.
//  Copyright © 2019 jbloit. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    let volume = Audio.volume()
    print(volume)
    let jackIsIn: Bool = Audio.jackIsIn()
    print(jackIsIn)

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

