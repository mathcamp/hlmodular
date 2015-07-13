//
//  FaceDetectorModule.swift
//  HLModular
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import UIKit
import CoreImage

public class FaceDetectorModule: HLModular.Module {
  public var detector: FaceDetector?
  
  public init() {
    super.init(id: "FaceDetector", lazy: true)
  }
  
  public override func handleStartModule() {
    detector = FaceDetector.sharedInstance
  }
}


public class DetectFacesJob: HLModular.Job {
  let image: UIImage
  let identifier: String
  
  public init(_ image: UIImage, identifier: String) {
    self.image = image
    self.identifier = identifier
    super.init(moduleId: "FaceDetector", usage: HLModular.ResourceUsage(cpu: .High, disk: .None, network: .None))
  }
  
  override func run() {
    NSLog("Begin detect faces \(identifier)")
    if let module = module as? FaceDetectorModule {
      if let detector = module.detector {
        let faces = detector.featuresInImage(CIImage(CGImage: image.CGImage))
        // now what?
      }
    }
    
    NSLog("Finish detect faces \(identifier)")
  }
}