//
//  HLModularTests.swift
//  HLModularTests
//
//  Created by Ben Garrett on 7/3/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import UIKit
import XCTest

class HLDBEntityTests: XCTestCase {
  let fileName = "entitydbfile"
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    let db = HLDB.DB.deleteDB(fileName)
    
    super.tearDown()
  }
  
  func entityTable(db: HLDB.DB, name: String) -> HLDB.Table {
    return HLDB.Table(db: db, name: name, fields: rollPhotoFields)
  }
  
  func testCreateEntityTable() {
    let finishedExpectation = expectationWithDescription("finished")
    
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
          
          table.drop()
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
    
    let db = HLDB.DB(fileName: fileName)
    let tableName = "createTable"
    let table = entityTable(db, name: tableName)
    table.create()
    
    var details = RollPhotoDetails()
    details.client_asset_url = "AAA"
    details.exif = "BBB"
    details.size = 1
    details.tz = "CCC"
    details.tz_offset = 2
    details.thumb = true
    details.thumb_size = 3
    details.type = "DDD"
    
    var entity = RollPhoto()
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
    entity.details = details
    
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
            let loadedEntity = RollPhoto(fields: item)
            
            // does the entity match?
            if loadedEntity != entity {
              XCTAssert(false, "Loaded entity does not match!")
            }
            
          } else {
            XCTAssert(false, "Unable to convert result row to [String: AnyObject]")
          }
        }
        
        table.drop()
        finishedExpectation.fulfill()
        return
      }
    }
    
    // Loop until the expectation is fulfilled
    waitForExpectationsWithTimeout(1, { error in
      XCTAssertNil(error, "Error")
    })
  }

  func testLoadFromJSON() {
    // load it from JSON file
    let testBundle = NSBundle(forClass: self.dynamicType)
    let jsonPath = testBundle.resourcePath?.stringByAppendingPathComponent("photos_mine.json")
    var loadedJSONData = NSData(contentsOfFile: jsonPath!)
    var error: NSError? = nil
    let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(loadedJSONData!, options: nil, error:&error)!

    // inflate this
    
    // NSLog("JSON Object=\(jsonObject)")
    if let fields = jsonObject as? [String: AnyObject] {
      var photoPage = RollPhotosPage(fields: fields)
      for photo in photoPage.page {
        NSLog("Got photo \(photo.toFields())")
      }
    }
  }
  
  func testUpdateEntity() {
    let finishedExpectation = expectationWithDescription("finished")
    
    let db = HLDB.DB(fileName: fileName)
    let tableName = "updateTable"
    let table = entityTable(db, name: tableName)
    table.create()
    
    var details = RollPhotoDetails()
    details.client_asset_url = "AAA"
    details.exif = "BBB"
    details.size = 1
    details.tz = "CCC"
    details.tz_offset = 2
    details.thumb = true
    details.thumb_size = 3
    details.type = "DDD"
    
    var entity = RollPhoto()
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
    entity.details = details
    
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
      
      table.update([row])
      
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
              let loadedEntity = RollPhoto(fields: item)
              
              // does the entity match?
              if loadedEntity != entity {
                XCTAssert(false, "Loaded entity does not match!")
              }
              
            } else {
              XCTAssert(false, "Unable to convert result row to [String: AnyObject]")
            }
        }

        table.drop()
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
