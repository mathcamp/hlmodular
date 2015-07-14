//
//  RollPhoto.swift
//  HLModular
//
//  Created by Ben Garrett on 7/10/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public let RollPhotoFields: [HLDB.Table.Field] =
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

public class RollPhoto: HLDB.Entity {
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
            "is_tip_card"      : is_tip_card,
            "default_image"    : default_image ]
  }
}


class RollPhotoDescription: HLDB.Entity {
  
}