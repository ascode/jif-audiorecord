//
//  ViewController.swift
//  jif-audiorecord
//
//  Created by 金飞 on 15/12/26.
//  Copyright © 2015年 Fei Jin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var avRec : AVAudioRecorder!
    var avUrl : NSURL!
    var avPlayer : AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avUrl = (NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as NSURL).URLByAppendingPathComponent("rec")
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        do{
            avRec = try AVAudioRecorder(URL: avUrl , settings: recordSettings)
            avRec.prepareToRecord()
        } catch let err as NSError{
            avRec = nil
            print(err.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func btnStartRecordPressed(sender: AnyObject) {
        avRec.record()
        
    }
    
    @IBAction func btnStopRecordPressed(sender: AnyObject) {
        avRec.stop()
    }
    
    @IBAction func btnPlayRecordPressed(sender: AnyObject) {
        do{
            avPlayer = try AVAudioPlayer(contentsOfURL: avUrl)
            avPlayer.prepareToPlay()
            avPlayer.play()
        }catch let err as NSError{
            avPlayer = nil
            print(err.localizedDescription)
        }
            
    }

}

