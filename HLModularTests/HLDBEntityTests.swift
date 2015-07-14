//
//  HLModularTests.swift
//  HLModularTests
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import UIKit
import XCTest

public let rollPhotoFields: [HLDB.Table.Field] =
[ HLDB.Table.Field(name: "photo_id",         type: .Text, index: .Primary, defaultValue: .NonNull),
  HLDB.Table.Field(name: "remote_asset_url", type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "title",            type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "subtitle",         type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "likes",            type: .Integer, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "self_like",        type: .Integer, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "taken_at",         type: .Real, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "taken_by",         type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "is_tip_card",      type: .Real, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "default_image",    type: .Text, index: .None, defaultValue: .NonNull) ]


public class TestEntity: HLDB.Entity {
  lazy public var photo_id: String         = self.stringValue("photo_id")
  lazy public var remote_asset_url: String = self.stringValue("remote_asset_url")
  lazy public var title: String            = self.stringValue("title")
  lazy public var subtitle: String         = self.stringValue("subtitle")
  lazy public var likes: Int               = self.intValue("likes")
  lazy public var self_like: Bool          = self.boolValue("self_like")
  lazy public var taken_at: Double         = self.doubleValue("taken_at")
  lazy public var taken_by: String         = self.stringValue("taken_by")
  lazy public var is_tip_card: Bool        = self.boolValue("is_tip_card")
  lazy public var default_image: String    = self.stringValue("default_image")
  
  override public func toFields() -> [String: AnyObject] {
    return ["photo_id"         : photo_id,
            "remote_asset_url" : remote_asset_url,
            "title"            : title,
            "subtitle"         : subtitle,
            "likes"            : likes,
            "self_like"        : self_like,
            "taken_at"         : taken_at,
            "taken_by"         : taken_by,
            "is_tip_card"      : is_tip_card,
            "default_image"    : default_image ]
  }
}


class HLDBEntityTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func entityTable(db: HLDB.DB, name: String) -> HLDB.Table {
    return HLDB.Table(db: db, name: name, fields: rollPhotoFields)
  }
  
  func testCreateEntityTable() {
    let finishedExpectation = expectationWithDescription("finished")
    
    let fileName = "dbfile"
    let db = HLDB.DB(fileName: fileName)
    let tableName = "Mucus"
    let table = entityTable(db, name: tableName)
    table.create()
    
    db.query("select name from sqlite_master where type='table'").onSuccess { result in
      switch result {
      case .Success:
        XCTAssert(false, "Tables query returned success rather than the tables")
      case .Error(let code, let message):
        XCTAssert(false, "Tables query returned error \(code) \(message)")
      case .Items(let arr):
        if arr.count != 1 {
          XCTAssert(false, "Expected one table")
        }
        let firstItem = arr[0]
        if let t = firstItem["name"] as? String {
          if t != tableName {
            XCTAssert(false, "Expected found table name to match")
          }
        } else {
          XCTAssert(false, "Expected table name to be a string")
        }
      }
      
      table.drop()
      db.query("select name from sqlite_master where type='table'").onSuccess { result in
        switch result {
        case .Success:
          XCTAssert(false, "Tables query returned success rather than the tables")
        case .Error(let code, let message):
          XCTAssert(false, "Tables query returned error \(code) \(message)")
        case .Items(let arr):
          if arr.count != 0 {
            XCTAssert(false, "Expected zero tables")
          }
          
          finishedExpectation.fulfill()
        }
      }
    }
    
    // Loop until the expectation is fulfilled
    waitForExpectationsWithTimeout(1, { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testCreateEntityTest() {
    let finishedExpectation = expectationWithDescription("finished")
    
    let fileName = "dbfile"
    let db = HLDB.DB(fileName: fileName)
    let tableName = "createTable"
    let table = entityTable(db, name: tableName)
    table.create()
    
    var entity = TestEntity()
    entity.photo_id = "AAAA"
    entity.remote_asset_url = "BBBB"
    entity.title = "CCCC"
    entity.subtitle = "DDDD"
    entity.likes = 5
    entity.self_like = true
    entity.taken_at = 7.0
    entity.taken_by = "EEEE"
    entity.is_tip_card = true
    entity.default_image = "FFFF"
    let row = HLDB.Table.Row(fields: entity.toFields())
    table.insert([row]).onSuccess { result in
      switch result {
        case .Success:
          break
        case .Error(let code, let message):
          XCTAssert(false, "Tables query returned error \(code) \(message)")
        case .Items(let arr):
          XCTAssert(false, "Tables query returned items rather than success")
      }
      
      table.select().onSuccess { result in
        
        switch result {
          case .Success:
            XCTAssert(false, "Tables query returned success rather than the tables")
          case .Error(let code, let message):
            XCTAssert(false, "Tables query returned error \(code) \(message)")
          case .Items(let arr):
            // expected to get one item
            if arr.count != 1 {
              XCTAssert(false, "Expected to get one row back")
            }
          
            // convert to an entity
            if let item = arr[0] as? [String: AnyObject] {
              let loadedEntity = TestEntity(fields: item)
              
              // does the entity match?
              
            } else {
              XCTAssert(false, "Unable to convert result row to [String: AnyObject]")
            }
        }
        
        finishedExpectation.fulfill()
        return
      }
    }
    
    // Loop until the expectation is fulfilled
    waitForExpectationsWithTimeout(1, { error in
      XCTAssertNil(error, "Error")
    })
  }
  
}
