//
//  PhotosModule.swift
//  HLModular
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation
import Photos

//* IMAGES STUFF *//

public class Asset {
  var asset: PHAsset
  var faces: [CIFaceFeature]
  
  var data: NSData {
    return NSData()
  }
  
  init(asset: PHAsset, faces: [CIFaceFeature] = []) {
    self.asset = asset
    self.faces = faces
  }
}

public class ImageAsset: Asset {
  var image: UIImage
  
  override var data: NSData {
    return NSData(data: UIImageJPEGRepresentation(image, 0.3))
  }
  
  init?(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode = .AspectFit) {
    let imageManager = PHImageManager.defaultManager()
    var foundImage: UIImage?
    var options = PHImageRequestOptions()
    
    options.synchronous = true
    
    imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: options) { image, info in
      if info[PHImageErrorKey] == nil {
        foundImage = image
      }
    }
    
    if let image = foundImage {
      self.image = image
      super.init(asset: asset)
    } else { // initialization failed; set default values for stored properties
      self.image = UIImage()
      super.init(asset: asset)
      
      return nil
    }
  }
}

// IMAGES STUFF



public class PhotosModule: HLModular.Module {
  public init() {
    super.init(id: "Photos", lazy: true)
  }
  
  public override func handleStartModule() {
    let imageManager = PHImageManager.defaultManager()
  }
}

extension PHFetchResult: SequenceType {
  public func generate() -> NSFastGenerator {
    return NSFastGenerator(self)
  }
}

public class FetchPhotosJob: HLModular.Job {
  public init() {
    super.init(moduleId: "Photos", usage: HLModular.ResourceUsage(cpu: .High, disk: .High, network: .None))
  }
  
  override func run() {
    NSLog("Running fetch photos job!")
    let before = NSDate()
    var imageAssets = [PHAsset]()
    
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    fetchOptions.predicate = NSPredicate(format: "creationDate < %@", before)

    for obj in PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions) {
      let asset = obj as PHAsset
      imageAssets.append(asset)

      // start the job to process the asset
      run(FetchPhotoJob(asset))
    }
    dataOut = HLModular.Data(imageAssets)
    NSLog("Done with fetch job, got \(imageAssets.count)!")
  }
}


public class FetchPhotoJob: HLModular.Job {
  let asset: PHAsset
  
  public init(_ asset: PHAsset) {
    self.asset = asset
    super.init(moduleId: "Photos", usage: HLModular.ResourceUsage(cpu: .High, disk: .High, network: .None))
  }
  
  override func run() {
    NSLog("Started fetching photo! \(asset.localIdentifier)")
    if let imageAsset = ImageAsset(asset: asset, size: CGSize(width: 640, height: 640)) {
      dataOut = HLModular.Data(imageAsset)
      run(DetectFacesJob(imageAsset.image, identifier: imageAsset.asset.localIdentifier))
      
      // should be able to handle failure
    }
    NSLog("Finished fetching photo! \(asset.localIdentifier)")
  }
}