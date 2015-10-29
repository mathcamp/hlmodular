//
//  HLModular.swift
//  HLModular
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public class HLModular {

  public enum Degree {
    case Low
    case Medium
    case High
    case None
  }
  
  public enum Priority {
    case Low
    case High
  }
  
  public enum State: Printable {
    case Uninited
    case Starting
    case Running
    case Stopping
    
    public var description: String {
      switch self {
      case .Uninited: return "Uninited"
      case .Starting: return "Starting"
      case .Running: return "Running"
      case .Stopping: return "Stopping"
      }
    }
  }
  
  public enum Concurrency {
    case Concurrent
    case Serial
    case Main
  }
  
  public class ResourceUsage {
    let cpu: Degree
    let disk: Degree
    let network: Degree
    
    public init(cpu: Degree, disk: Degree, network: Degree) {
      self.cpu = cpu
      self.disk = disk
      self.network = network
    }
  }
  
  public class Module {
    let usage: ResourceUsage
    let id: String
    let concurrency: Concurrency
    let lazy: Bool
    let lock = NSLock()
    var state: State = .Uninited {
      didSet {
        NSLog("Module=\(id) state changed: \(state)")
      }
    }
    
    public init(id: String,
                lazy: Bool = true,
                concurrency: Concurrency = .Concurrent,
                usage: ResourceUsage = HLModular.ResourceUsage(cpu: .None, disk: .None, network: .None)) {
      self.id = id
      self.lazy = lazy
      self.concurrency = concurrency
      self.usage = usage
    }
    
    public func start(queue: dispatch_queue_t, completion: ((Module) -> ())? = nil) {
      if state == .Running {
        completion?(self)
        return
      }
      lock.lock()
      state = .Starting
      
      dispatch_async(queue) {
        self.startModule({
          self.state = .Running
          self.lock.unlock()
          completion?(self)
        })
      }
    }
    
    func startModule(completion: (() -> ())) {
      handleStartModule()
      completion()
    }
    
    public func handleStartModule() {
      // override this in your subclass
    }
    
    public func stop() {
      
    }
  }
  
  public class Data {
  }
    
  public class Runner {
    var modules: [String: Module] = [:]
    private let moduleQueue = dispatch_queue_create("hlmodular.module.queue", nil)
    private let jobQueue = dispatch_queue_create("hlmodular.job.queue", nil)
    private let concurrentJobQueue = dispatch_queue_create("hlmodular.job.concurrentqueue",  DISPATCH_QUEUE_CONCURRENT)
    
    public init() {
      // nothing to do here
    }
    
    public func addModule(module: Module) {
      modules[module.id] = module
    }
    
    public func start() {
      for (id, module) in modules {
        module.start(moduleQueue)
      }
    }
    
    public func run(job: HLModularRunnable) -> Bool {
      if let module = modules[job.getModuleId()] {
        let concurrency = module.concurrency
        var q = concurrentJobQueue
        switch concurrency {
          case .Serial:
            q = jobQueue
          case .Main:
            q = dispatch_get_main_queue()
          case .Concurrent:
            q = concurrentJobQueue
        }
        
        switch module.state {
          case .Running:
            dispatch_async(q) {
              job.run(self, module: module)
            }
          
          default:
            module.start(moduleQueue, completion: { module in
              dispatch_async(q) {
                job.run(self, module: module)
              }
            })
        }
        return true
      }
      
      NSLog("HLModular::Runner, unknown module")
      return false
    }
    
  }
}

public class UIModule: HLModular.Module {
  public init() {
    super.init(id: "UI", lazy: true)
  }
}


