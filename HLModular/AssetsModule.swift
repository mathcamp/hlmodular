//
//  AssetsModule.swift
//  HLModular
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import UIKit
import AssetsLibrary

public class AssetsModule: HLModular.Module {
  var library: ALAssetsLibrary?
  public init() {
    super.init(id: "Assets", lazy: true, concurrency: .Serial)
  }
  
  public override func handleStartModule() {
    library = ALAssetsLibrary()
  }
}

public class AssetsModuleJob: HLModular.Job {
  public init(usage: HLModular.ResourceUsage) {
    super.init(moduleId: "Assets", usage: usage)
  }
}

public class FetchAssetsJob: AssetsModuleJob {
  let groupType: ALAssetsGroupType
  public init(groupType: ALAssetsGroupType = ALAssetsGroupType(ALAssetsGroupAlbum)) {
    self.groupType = groupType
    super.init(usage: HLModular.ResourceUsage(cpu: .High, disk: .High, network: .None))
  }
  
  func handleGroup(group: ALAssetsGroup) {
    let groupAssetCallback: (result: ALAsset!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> () = { result, idx, stop in
      NSLog("Got asset \(result)")
      if result != nil {
        self.run(FetchAssetJob(result))
      }
      return
    }
    
    group.setAssetsFilter(ALAssetsFilter.allAssets())
    group.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: groupAssetCallback)
  }
  
  override func run() {
    NSLog("Searching Assets!")
    if let module = module as? AssetsModule {
      if let library = module.library {
        var groups = [ALAssetsGroup]()
        
        library.enumerateGroupsWithTypes(groupType,
          usingBlock: {(group, stop) in
            if let g = group {
              NSLog("AssetGenerator::enumeratePhotoGroups: Group \(g)")
              self.handleGroup(group)
            } else {
              // failure
            }
          },
          failureBlock: { (error: NSError!) in
            NSLog("Problem loading albums: \(error)")
        })
      }
    }
  }
}

public class FetchAssetJob: AssetsModuleJob {
  let asset: ALAsset
  
  public init(_ asset: ALAsset) {
    self.asset = asset
    super.init(usage: HLModular.ResourceUsage(cpu: .High, disk: .High, network: .None))
  }
  
  override func run() {
    NSLog("Fetching Asset!")
    if let rep = asset.defaultRepresentation() {
      if let image = UIImage(CGImage: rep.fullScreenImage().takeUnretainedValue()) {
        dataOut = HLModular.Data(image)
        run(DetectFacesJob(image, identifier: rep.url().absoluteString!))
      }
    }
    NSLog("Done Fetching Asset!")
  }
}