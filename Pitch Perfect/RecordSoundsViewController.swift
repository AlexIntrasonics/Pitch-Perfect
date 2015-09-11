//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Alex Redshaw on 08/09/2015.
//  Copyright (c) 2015 Alex Redshaw. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!;
    var recordedAudio:RecordedAudio!;
    
    var appColorBlue = UIColor(red: 33.0/255.0, green: 73.0/255.0, blue: 111.0/255.0, alpha: 1.0);
    var isRecording = false;
    var isPaused = false;
    var usePresetFilename = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag)
        {
            // Store information for next ViewController
            recordedAudio = RecordedAudio(iFilePathURL: recorder.url, iTitle: recorder.url.lastPathComponent!);
            self.performSegueWithIdentifier("stopRecordingSegue", sender: recordedAudio);
        }
        else
        {
            println("WARNING: Failed to record");
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecordingSegue")
        {
            let playSoundsViewController:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController;
            let data = sender as! RecordedAudio;
            playSoundsViewController.receivedAudio = data;
        }
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        stopButton.hidden = false;
        stopButton.enabled = true;
        
        if(!isRecording) // Start recording
        {
            isRecording = true;
            isPaused = false;
            recordingLabel.text = "Recording...\n(Tap to pause)";
            recordingLabel.textColor = UIColor.redColor();
            
            // Setup recorder filepaths
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String;
            let pathArray:AnyObject;
            
            if(usePresetFilename) // Use preset filename
            {
                pathArray = [dirPath, "recording.wav"];
            }
            else // Use unique filename (timestamped)
            {
                var currentDateTime = NSDate();
                var formatter = NSDateFormatter();
                formatter.dateFormat = "ddMMyyyy-HHmmss";
                var recordingName = formatter.stringFromDate(currentDateTime) + ".wav";
                pathArray = [dirPath, recordingName];
            }
            var recordingPath = NSURL.fileURLWithPathComponents(pathArray as! [AnyObject]);
            
            println("INFO: RecordingPath = \(recordingPath!)");
            
            // Setup & run recorder
            let session = AVAudioSession.sharedInstance();
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil);
            
            audioRecorder = AVAudioRecorder(URL: recordingPath, settings: nil, error: nil);
            audioRecorder.delegate = self;
            audioRecorder.meteringEnabled = true;
            audioRecorder.prepareToRecord();
            audioRecorder.record();
            
            println("INFO: Recording started");
        }
        else if(!isPaused) // Pause recording
        {
            isPaused = true;
            recordingLabel.text = "Paused recording\n(Tap to unpause)";
            recordingLabel.textColor = appColorBlue;
            
            audioRecorder.pause();
            println("INFO: Recording paused");
        }
        else // Unpause recording
        {
            isPaused = false;
            recordingLabel.text = "Recording...\n(Tap to pause)";
            recordingLabel.textColor = UIColor.redColor();
            
            audioRecorder.record();
            println("INFO: Recording unpaused");
        }
        
        println("INFO: recordAudio pressed");
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        isRecording = false;
        stopButton.hidden = true;
        stopButton.enabled = false;
        recordingLabel.text = "Tap to Record";
        recordingLabel.textColor = appColorBlue;
        
        audioRecorder.stop();
        let audioSession = AVAudioSession.sharedInstance();
        audioSession.setActive(false, error: nil);
        
        println("INFO: stopRecording pressed");
    }
}
