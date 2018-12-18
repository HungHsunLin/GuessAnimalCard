//
//  ViewController.swift
//  MemeryCard
//
//  Created by 弘勳 on 2018/10/19.
//  Copyright © 2018 Hung Hsun Lin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var startBGM: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let startBGMPath = Bundle.main.path(forResource: "startBGM", ofType: "mp3")
        do {
            startBGM = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: startBGMPath!))
            
            // Set play times is 0 to play once.
            startBGM.numberOfLoops = 0
        } catch {
            print("error")
        }
    }
    
    override func viewLayoutMarginsDidChange() {
        startBGM.play()
    }
    
    @IBAction func pressedPlayBtn(_ sender: Any) {
        startBGM.pause()
    }
    
    
}

