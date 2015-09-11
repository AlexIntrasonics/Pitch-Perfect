//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Alex Redshaw on 09/09/2015.
//  Copyright (c) 2015 Alex Redshaw. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(iFilePathURL: NSURL, iTitle: String)
    {
        filePathUrl = iFilePathURL;
        title = iTitle;
    }
}
