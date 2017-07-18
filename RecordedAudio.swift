//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Chris Huang on 7/31/15.
//  Copyright (c) 2015 Chris Huang. All rights reserved.
//

import Foundation

class RecordedAudio {
    var filePathUrl: URL!
    var title: String!
    
    init (filePathUrl: URL!, title: String!) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
