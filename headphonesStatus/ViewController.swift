//
//  ViewController.swift
//  headphonesStatus
//
//  Created by julien@macmini on 23/09/2019.
//  Copyright © 2019 jbloit. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    

    @IBOutlet weak var outputLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onJackChanged(_:)), name: NSNotification.Name.init(rawValue: "JackChanged"), object: nil)
        
        
        // init the singleton
        if(Audio.shared() != nil)
        {
            let jackIsIn: Bool = Audio.isJackIn()
            print(jackIsIn)
            updateHeadphonesLabel()
        }

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func onJackChanged(_ notification:Notification) {
        // Do something now
        print("[SWIFT]JACK IN \(Audio.isJackIn())")
        updateHeadphonesLabel()

    }
    
    func updateHeadphonesLabel(){
        if (Audio.isJackIn()){
            outputLabel?.stringValue = "HEADPHONES IN"
        } else {
            outputLabel?.stringValue = "HEADPHONES OUT"
        }
    }


    
}

