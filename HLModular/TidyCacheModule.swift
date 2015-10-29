//
//  TidyCacheModule.swift
//  HLModular
//
//  Created by Ben Garrett on 9/11/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public class TidyCacheModule: HLModular.Module {
  public struct File {
    let path: String
    let size: UInt64
    let ts: NSTimeInterval
    
    public init(path: String, size: UInt64?, ts: NSTimeInterval?) {
      self.path = path
      if let size = size { self.size = size }
      else { self.size = 0 }
      if let ts = ts { self.ts = ts }
      else { self.ts = 0 }
    }
  }

  lazy var fileManager: NSFileManager = { NSFileManager.defaultManager() }()
  
  public init() {
    super.init(id: "TidyCache", lazy: true, concurrency: .Serial)
  }
}

public class TidyCacheFindFilesDataIn: HLModular.Data {
  public let targetDir: String = ""
  public let targetSizeKB: Int = 0
}

public class TidyCacheFindFilesJobBase<Module: TidyCacheModule, DataIn: TidyCacheFindFilesDataIn, DataOut: HLModular.Data>: HLModularJobBase<Module, DataIn, DataOut> {

  public init(dataIn: DataIn) {
    super.init(moduleId: "TidyCache", usage: HLModular.ResourceUsage(cpu: .Low, disk: .High, network: .None), dataIn: dataIn)
  }

  func fileForPath(fileManager: NSFileManager, path: String) -> TidyCacheModule.File? {
    let attributes: NSDictionary? = fileManager.attributesOfItemAtPath(path, error: nil)
    if let dict = attributes {
      let size = (dict[NSFileSize as NSString] as? NSNumber)?.unsignedLongLongValue
      let ts = (dict[NSFileModificationDate as NSString] as? NSDate)?.timeIntervalSince1970
      return TidyCacheModule.File(path: path, size: size, ts: ts)
    } else {
      return nil
    }
  }
  
  override func execute(module: Module) -> DataOut? {
    // first, find all the files in the directory
    var files: [TidyCacheModule.File] = []
    if let enumerator = module.fileManager.enumeratorAtPath(dataIn.targetDir) {
      while let path = enumerator.nextObject() as? String {
        if let file = fileForPath(module.fileManager, path: path) {
          files.append(file)
        }
      }
    }
    
    // second, sort them by date ascending
    
    // delete the necessary files
    if count(files) > 0 {
      run(TidyCacheDeleteFilesJob(deleteFiles: files))
    }
    
    return nil
  }
}
public typealias TidyCacheFindFilesJob = TidyCacheFindFilesJobBase<TidyCacheModule, TidyCacheFindFilesDataIn, HLModular.Data>


public class TidyCacheDeleteFilesDataIn: HLModular.Data {
  let deleteFiles: [TidyCacheModule.File]
  init(deleteFiles: [TidyCacheModule.File]) {
    self.deleteFiles = deleteFiles
  }
}

public class TidyCacheDeleteFilesJobBase<Module: TidyCacheModule, DataIn: TidyCacheDeleteFilesDataIn, DataOut: HLModular.Data>: HLModularJobBase<Module, DataIn, DataOut> {

  public convenience init(deleteFiles: [TidyCacheModule.File]) {
    self.init(dataIn: DataIn(deleteFiles: deleteFiles))
  }
  
  public init(dataIn: DataIn) {
    super.init(moduleId: "TidyCache", usage: HLModular.ResourceUsage(cpu: .Low, disk: .High, network: .None), dataIn: dataIn)
  }
  
  override func execute(module: Module) -> DataOut? {
    let fileManager = NSFileManager.defaultManager()
    for file in dataIn.deleteFiles {
      
    }
    return nil
  }
}
public typealias TidyCacheDeleteFilesJob = TidyCacheDeleteFilesJobBase<TidyCacheModule, TidyCacheDeleteFilesDataIn, HLModular.Data>