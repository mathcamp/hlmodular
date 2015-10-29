//
//  HLModularGeneric.swift
//  HLModular
//
//  Created by Ben Garrett on 9/11/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public protocol HLModularRunnable {
  func getModuleId() -> String
  func run(runner: HLModular.Runner, module: HLModular.Module)
}

public class HLModularJobBase<Module, DataIn, DataOut>: HLModularRunnable {
  var module: Module?
  var dataIn: DataIn
  var dataOut: DataOut?
  let usage: HLModular.ResourceUsage
  let moduleId: String
  let priority: HLModular.Priority
  weak var runner: HLModular.Runner?
  
  public init(moduleId: String, usage: HLModular.ResourceUsage, dataIn: DataIn, priority: HLModular.Priority = .Low) {
    self.moduleId = moduleId
    self.usage = usage
    self.priority = priority
    self.dataIn = dataIn
  }

  public func getModuleId() -> String {
    return moduleId
  }
  
  public func run(runner: HLModular.Runner, module: HLModular.Module) {
    self.runner = runner
    if let module = module as? Module {
      self.module = module
      dataOut = execute(module)
    }
  }
  
  func execute(module: Module) -> DataOut? {
    // override in subclass
    return nil
  }
  
  public func run(job: HLModularRunnable) -> Bool {
    if let r = runner {
      r.run(job)
      return true
    }
    return false
  }
}

public typealias HLModularJob = HLModularJobBase<HLModular.Module, HLModular.Data, HLModular.Data>
public class ExampleModule: HLModular.Module {
  public init() {
    super.init(id: "Example", lazy: true, concurrency: .Serial)
  }
}

public class ExampleCacheJob<Module: ExampleModule, DataIn: HLModular.Data, DataOut: HLModular.Data>: HLModularJob {
  public init(usage: HLModular.ResourceUsage, dataIn: DataIn) {
    super.init(moduleId: "Example", usage: usage, dataIn: dataIn)
  }
}