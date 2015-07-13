//
//  RollPhoto.swift
//  HLModular
//
//  Created by Ben Garrett on 7/10/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

class RollPhoto: HLDB.Entity {
  lazy var photo_id: String { stringValue("photo_id") }
  lazy var remote_asset_url: String { stringValue("remote_asset_url") }
  lazy var title: String { stringValue("title") }
  lazy var subtitle: String { stringValue("subtitle") }
  lazy var likes: Int { intValue("likes") }
  lazy var self_like: Bool { boolValue("self_like") }
  lazy var taken_at: Double { doubleValue("taken_at") }
  lazy var taken_by: String { boolValue("taken_by") }
  lazy var is_tip_card: Bool { boolValue("is_tip_card") }
  lazy var default_image: String { boolValue("default_image") }
  
  override public func toFields() -> [String: AnyObject] {
    return ["photo_id": photo_id,
            "remote_asset_url": remote_asset_url,
            "title": title,
            "subtitle" : subtitle,
            "likes" : likes,
            "self_like" : self_like,
            "taken_at" : taken_at,
            "is_tip_card" : is_tip_card,
            "default_image": default_image ]
  }
}


class RollPhotoDescription: HLDB.Entity {
  
}