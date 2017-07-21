//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Chris Huang on 7/23/15. Updated to SWIF2,3 7/18/17
//  Adding mix channel playback feature 7/20/17
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
    }
    
    @IBAction func playChipmunkAudio(_ sender: AnyObject) {
        // play chipmunk by change higher pitch
        audioEffect("pitch", pitch: 1000)
    }
    
    @IBAction func playDarthvaderAudio(_ sender: UIButton) {
        // play vader by change lower pitch
        audioEffect("pitch", pitch: -1000)
    }
    
    @IBAction func playFastAudio(_ sender: UIButton) {
        // play rabit by chnage play rate to 2.0
        playAtRate(2.0)
    }
    
    @IBAction func playReverb(_ sender: UIButton) {
        // play revert audio
        audioEffect("reverb", pitch: 0)
    }
    
    @IBAction func playEcho(_ sender: UIButton) {
        // play echo parrott
        audioEffect("echo", pitch: 0)
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        stopPlayback()
    }
    
    @IBAction func playSlowAudio(_ sender: UIButton) {
        // play snail speed
        playAtRate(0.5)
    }
    
    @IBAction func playMixEffects(_ sender: UIButton) {
        // play revert audio
        audioEffect("mixer", pitch: 1000)
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.rate = 1.0
    }
    
    func audioEffect(_ effect: String, pitch: Float) {
        stopPlayback()
        
        let playerNode1 = AVAudioPlayerNode()
        let playerNode2 = AVAudioPlayerNode()
        var mixerToggle = false
        
        playerNode1.volume = 1
        playerNode2.volume = 1
        
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        
        try! audioFile.read(into: buffer)
        
        audioEngine.attach(playerNode1)
        audioEngine.attach(playerNode2)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        let reverbEffect = AVAudioUnitReverb()
        let delayEffect = AVAudioUnitDelay()
        
        switch effect {
        case "pitch":
            changePitchEffect.pitch = pitch
            audioEngine.attach(changePitchEffect)
            
            connectToAudio(playerNode: playerNode1, effect: changePitchEffect, buffer: buffer)
        case "reverb":
            reverbEffect.loadFactoryPreset(.largeRoom2)
            reverbEffect.wetDryMix = 80
            
            audioEngine.attach(reverbEffect)
            
            connectToAudio(playerNode: playerNode1, effect: reverbEffect, buffer: buffer)
        case "echo":
            delayEffect.delayTime = 1.5
            delayEffect.feedback = 20
            
            audioEngine.attach(delayEffect)
            
            connectToAudio(playerNode: playerNode1, effect: delayEffect, buffer: buffer)
        case "mixer":
            mixerToggle = true
            changePitchEffect.pitch = pitch
            audioEngine.attach(changePitchEffect)
            
            reverbEffect.loadFactoryPreset(.largeRoom2)
            reverbEffect.wetDryMix = 80
            
            audioEngine.attach(reverbEffect)
            
            connectToAudio(playerNode: playerNode1, effect: changePitchEffect, buffer: buffer)
            connectToAudio(playerNode: playerNode2, effect: reverbEffect, buffer: buffer)
        default: break
        }
        
        if mixerToggle == true {
            playerNode1.volume = 0.5
            playerNode2.volume = 0.5
            
            playerNode1.scheduleBuffer(buffer, at: nil, completionHandler: nil)
            playerNode2.scheduleBuffer(buffer, at: nil, completionHandler: nil)
            
            try! audioEngine.start()
            
            audioEngine.prepare()
            playerNode1.play()
            playerNode2.play()

        } else {
            playerNode1.scheduleBuffer(buffer, at: nil, completionHandler: nil)
            
            try! audioEngine.start()
            
            audioEngine.prepare()
            playerNode1.play()
        }
    }
    
    func connectToAudio(playerNode: AVAudioPlayerNode, effect: AnyObject, buffer: AVAudioPCMBuffer) {
        audioEngine.connect(playerNode, to: effect as! AVAudioNode, format: buffer.format)
        audioEngine.connect(effect as! AVAudioNode, to: audioEngine.mainMixerNode, format: buffer.format)
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

