//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Chris Huang on 7/14/15. Updated to SWIF2,3 7/18/17
//  Copyright (c) 2015 Chris Huang. All rights reserved.
//

import UIKit
import AVFoundation

struct Colors {
    static let blue = UIColor(red: 0.101961, green: 0.219608, blue: 0.360784, alpha: 1.0)
    static let red = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
}

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var pauseAudio: Bool = false
    
    var pauseIcon = UIImage(named: "pauseButton")
    var recordIcon = UIImage(named: "microphone")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordingName = "my_audio.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(recordingName)
        
        let session = AVAudioSession.sharedInstance()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        
        audioRecorder = try! AVAudioRecorder(url: filePath, settings: settings)
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stopButton.isHidden = true
        recordButton.isEnabled = true
        statusText.text = "Tap to record!"
        statusText.textColor = Colors.blue
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        if (pauseAudio) {
            recordButton.setImage(recordIcon, for:UIControlState());
            statusText.text = "Tap to resume recording!"
            statusText.textColor = Colors.blue
            
            audioRecorder.pause()
            pauseAudio = false
        } else {
            recordButton.setImage(pauseIcon, for:UIControlState());
            statusText.text = "Recording in progress!"
            statusText.textColor = Colors.red
            stopButton.isHidden = false
            
            audioRecorder.record()
            pauseAudio = true
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        } else {
            recordButton.isEnabled = true
            stopButton.isHidden = true
            
            let alertController = UIAlertController(title: "Warning!", message:
                "An error has occurred\n Recording was not successful", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        pauseAudio = false
        recordButton.setImage(recordIcon, for:UIControlState());
    }
}
