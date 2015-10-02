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
            audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl);
            audioPlayer.enableRate = true;
            audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl);
        }
        else // Use preset file
        {
            if let audioFilePath = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3")
            {
                let audioFilePathURL = NSURL.fileURLWithPath(audioFilePath);
                audioPlayer = try? AVAudioPlayer(contentsOfURL: audioFilePathURL);
                audioPlayer.enableRate = true;
                audioFile = try? AVAudioFile(forReading: audioFilePathURL);
            }
            else
            {
                print("WARNING: audioFilePath is empty");
            }
        }
        
        audioEngine = AVAudioEngine();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }

    func playAtRate(rate: Float) {
        stopAudio();
        audioPlayer.rate = rate;
        audioPlayer.play();
    }
    
    func playWithEffect(effectNode: AVAudioNode) {
        // Setup audioEngine with effect
        var audioPlayerNode = AVAudioPlayerNode();
        audioEngine.attachNode(audioPlayerNode);
        audioEngine.attachNode(effectNode);
        audioEngine.connect(audioPlayerNode, to: effectNode, format: nil);
        audioEngine.connect(effectNode, to: audioEngine.outputNode, format: nil);
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil);
        do
        {
            try audioEngine.start()
        }
        catch _
        {
        }
        
        audioPlayerNode.play();
    }
    
    func playAtPitch(pitch: Float) {
        stopAudio();
        
        // Playback pitch-altered audio
        let audioUnitTimePitch = AVAudioUnitTimePitch();
        audioUnitTimePitch.pitch = pitch;
        playWithEffect(audioUnitTimePitch);
    }
    
    func playbackWithReverb(wetDryMix: Float, roomSetting: AVAudioUnitReverbPreset) {
        stopAudio();
        
        // Playback reverb-modulated audio
        let audioUnitReverb = AVAudioUnitReverb();
        audioUnitReverb.wetDryMix = wetDryMix;
        audioUnitReverb.loadFactoryPreset(roomSetting);
        playWithEffect(audioUnitReverb);
    }
    
    func stopAudio() {
        audioPlayer.stop();
        audioPlayer.currentTime = 0.0;
        audioEngine.stop();
        audioEngine.reset();
    }
    
    @IBAction func playbackSlow(sender: UIButton) {
        playAtRate(0.5);
        print("INFO: playbackSlow pressed");
    }
    
    @IBAction func playbackFast(sender: UIButton) {
        playAtRate(2.0);
        print("INFO: playbackFast pressed");
    }
    
    @IBAction func playbackPitchUp(sender: UIButton) {
        playAtPitch(1200);
        print("INFO: playbackPitchUp pressed");
    }
    
    @IBAction func playbackPitchDown(sender: UIButton) {
        playAtPitch(-600);
        print("INFO: playbackPitchDown pressed");
    }
    
    @IBAction func playbackReverb(sender: UIButton) {
        playbackWithReverb(50, roomSetting: AVAudioUnitReverbPreset.Cathedral);
        print("INFO: playbackReverb pressed");
    }
    
    @IBAction func playbackStop(sender: UIButton) {
        stopAudio();
        print("INFO: playbackStop pressed");
    }
}
