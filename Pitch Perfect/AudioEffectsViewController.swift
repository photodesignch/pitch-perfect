//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Chris Huang on 7/23/15. Updated to SWIF2,3 7/18/17
//  Copyright (c) 2015 Chris Huang. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Audio Effects"
        
        audioPlayer = try! AVAudioPlayer(contentsOf: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
    
    @IBAction func playChipmunkAudio(_ sender: AnyObject) {
       audioEffect("pitch", pitch: 1000)
    }
    
    @IBAction func playDarthvaderAudio(_ sender: UIButton) {
        audioEffect("pitch", pitch: -1000)
    }
    
    @IBAction func playReverb(_ sender: UIButton) {
        audioEffect("reverb", pitch: 0)
    }
    
    @IBAction func playEcho(_ sender: UIButton) {
        audioEffect("echo", pitch: 0)
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        stopPlayback()
    }
    
    @IBAction func playSlowAudio(_ sender: UIButton) {
        playAtRate(0.5)
    }

    @IBAction func playFastAudio(_ sender: UIButton) {
        playAtRate(2.0)
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.rate = 1.0
    }
    
    func audioEffect(_ effect: String, pitch: Float) {
        stopPlayback()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        let reverbEffect = AVAudioUnitReverb()
        let delayEffect = AVAudioUnitDelay()
        
        switch effect {
            case "pitch":
                changePitchEffect.pitch = pitch
                audioEngine.attach(changePitchEffect)
                
                audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
                audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
            case "reverb":
                reverbEffect.loadFactoryPreset(.largeRoom2)
                reverbEffect.wetDryMix = 80
                
                audioEngine.attach(reverbEffect)
                
                audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
                audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
            case "echo":
                delayEffect.delayTime = 1.5
                delayEffect.feedback = 20
                
                audioEngine.attach(delayEffect)
                
                audioEngine.connect(audioPlayerNode, to: delayEffect, format: nil)
                audioEngine.connect(delayEffect, to: audioEngine.outputNode, format: nil)
            default: break
        }
        
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }
    
    func playAtRate(_ rate: Float) {
        stopPlayback()
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
