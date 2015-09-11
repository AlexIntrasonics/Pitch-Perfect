//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Alex Redshaw on 09/09/2015.
//  Copyright (c) 2015 Alex Redshaw. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!;
    var audioEngine:AVAudioEngine!;
    var receivedAudio:RecordedAudio!;
    var audioFile:AVAudioFile!;
    
    var useRecorder = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(useRecorder) // Use recorder
        {
            audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil);
            audioPlayer.enableRate = true;
            audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        }
        else // Use preset file
        {
            if let audioFilePath = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3")
            {
                let audioFilePathURL = NSURL.fileURLWithPath(audioFilePath);
                audioPlayer = AVAudioPlayer(contentsOfURL: audioFilePathURL, error: nil);
                audioPlayer.enableRate = true;
                audioFile = AVAudioFile(forReading: audioFilePathURL, error: nil)
            }
            else
            {
                println("WARNING: audioFilePath is empty");
            }
        }
        
        audioEngine = AVAudioEngine();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playAtRate(rate: Float) {
        stopAudio();
        audioPlayer.rate = rate;
        audioPlayer.play();
    }
    
    func playAtPitch(pitch: Float) {
        stopAudio();
        
        // Setup audioEngine to playback pitch-altered audio
        let audioPlayerNode = AVAudioPlayerNode();
        let audioUnitTimePitch = AVAudioUnitTimePitch();
        audioUnitTimePitch.pitch = pitch;
        
        audioEngine.attachNode(audioPlayerNode);
        audioEngine.attachNode(audioUnitTimePitch);
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePitch, format: nil);
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.outputNode, format: nil);
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil);
        audioEngine.startAndReturnError(nil);
        audioPlayerNode.play();
    }
    
    func playbackWithReverb(wetDryMix: Float, roomSetting: AVAudioUnitReverbPreset)
    {
        stopAudio();
        
        // Setup audioEngine to playback reverb-modulated audio
        let audioPlayerNode = AVAudioPlayerNode();
        let audioUnitReverb = AVAudioUnitReverb();
        audioUnitReverb.wetDryMix = wetDryMix;
        audioUnitReverb.loadFactoryPreset(roomSetting);
        
        audioEngine.attachNode(audioPlayerNode);
        audioEngine.attachNode(audioUnitReverb);
        
        audioEngine.connect(audioPlayerNode, to: audioUnitReverb, format: nil);
        audioEngine.connect(audioUnitReverb, to: audioEngine.outputNode, format: nil);
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil);
        audioEngine.startAndReturnError(nil);
        audioPlayerNode.play();
    }
    
    func stopAudio()
    {
        audioPlayer.stop();
        audioPlayer.currentTime = 0;
        audioEngine.stop();
        audioEngine.reset();
    }
    
    @IBAction func playbackSlow(sender: UIButton) {
        playAtRate(0.5);
        println("INFO: playbackSlow pressed");
    }
    
    @IBAction func playbackFast(sender: UIButton) {
        playAtRate(2.0);
        println("INFO: playbackFast pressed");
    }
    
    @IBAction func playbackPitchUp(sender: UIButton) {
        playAtPitch(1200);
        println("INFO: playbackPitchUp pressed");
    }
    
    @IBAction func playbackPitchDown(sender: UIButton) {
        playAtPitch(-600);
        println("INFO: playbackPitchDown pressed");
    }
    
    @IBAction func playbackReverb(sender: UIButton) {
        playbackWithReverb(50, roomSetting: AVAudioUnitReverbPreset.Cathedral);
        println("INFO: playbackReverb pressed");
    }
    
    @IBAction func playbackStop(sender: UIButton) {
        stopAudio();
        println("INFO: playbackStop pressed");
    }
}
