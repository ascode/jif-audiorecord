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

    @IBOutlet var lblASRResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avUrl = (NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as NSURL).URLByAppendingPathComponent("rec")
        //压缩格式支持：pcm（不压缩）、wav、opus、speex、amr、x-flac
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM ),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 8000,
            AVNumberOfChannelsKey: 1
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
    
    
    @IBAction func btnASRPressed(sender: AnyObject) {
        var recdata = NSData(contentsOfURL: avUrl)//获取语音文件
//        let paths : NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        print(paths)
//        let documentsDirectory : NSString = paths.objectAtIndex(0) as! NSString
//        let appFile : NSString = documentsDirectory.stringByAppendingPathComponent("example_localRecord")
//        
//        let recdata : NSData = NSData(contentsOfFile: "example_localRecord.pcm")!
//        
//        print(NSBundle.mainBundle().pathForResource("example_localRecord", ofType: "pcm")!)
//        let recdata = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("example_localRecord.pcm", ofType: "pcm")!)
        print(recdata)
        //print(NSBundle.mainBundle().pathForResource("Info.plist", ofType: nil))
        print(NSBundle.mainBundle().URLForResource("少女时代-TaeTiSeo - Twinkle", withExtension: "mp3")!)
        print(NSBundle.mainBundle().URLForResource("tt.mp3", withExtension: nil))
        print(NSBundle.mainBundle().URLForResource("aa.pcm", withExtension: nil))
        let base64Data = recdata!.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)  //将语音数据转换成base64编码数据
        
        let urlForAccessToken = NSURL(string: "https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=tvSQAmNW3ka2IFlkDCYlbCMG&client_secret=2c289b2656bc5859d0100fd27f5a8762")
        if let theurl = urlForAccessToken {
            //从网络请求access_token
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: theurl) , queue: NSOperationQueue()) { (res:NSURLResponse?, data:NSData?, err:NSError?) -> Void in
                let arrdata:AnyObject?
                do{
                    try arrdata = NSJSONSerialization.JSONObjectWithData(NSData(data: data!), options: NSJSONReadingOptions.AllowFragments)
                    let access_token = arrdata?.objectForKey("access_token")! as! String //得到access_token
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: "http://vop.baidu.com/server_api?lan=zh&token=\(access_token)&cuid=jinfei")!)//配置url和控制信息
                    urlRequest.HTTPMethod = "POST"
                    urlRequest.setValue("audio/pcm;rate=8000", forHTTPHeaderField: "Content-Type")//设置语音格式和采样率
                    print(recdata!.length)
                    //print(base64Data)
                    urlRequest.setValue("\(recdata!.length)", forHTTPHeaderField: "Content-length")//设置原始语音长度

                    urlRequest.HTTPBody = base64Data //设置传送的语音数据
                    
                    NSURLConnection.sendAsynchronousRequest(urlRequest , queue: NSOperationQueue()) { (res:NSURLResponse?, data:NSData?, err:NSError?) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.lblASRResult.text = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        })
                        
                        print("语音解析结果:\(String(NSString(data: data!, encoding: NSUTF8StringEncoding)))")
                    }
                }catch{
                    print("没有获取到网络数据")
                }
                
            }
        }
        
        
        
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

