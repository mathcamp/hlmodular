//
//  ContactsModule.swift
//  HLModular
//
//  Created by Ben Garrett on 9/11/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public class ContactsModule: HLModular.Module {
  public init() {
    super.init(id: "Contacts", lazy: true, concurrency: .Serial)
  }
}

public class ContactsJob: HLModular.Job {
  public init(usage: HLModular.ResourceUsage) {
    super.init(moduleId: "Contacts", usage: usage)
  }
}

public class GatherContactsJob: ContactsJob {
  public init() {
    super.init(usage: HLModular.ResourceUsage(cpu: .High, disk: .Low, network: .None))
  }
  
  override func run() {
    
  }
}