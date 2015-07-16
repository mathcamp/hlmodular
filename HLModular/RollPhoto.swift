//
//  RollPhoto.swift
//  HLModular
//
//  Created by Ben Garrett on 7/10/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public func ==(lhs: RollPhotoDetails, rhs: RollPhotoDetails) -> Bool {
  return lhs.client_asset_url == rhs.client_asset_url &&
    lhs.exif == rhs.exif &&
    lhs.size == rhs.size &&
    lhs.tz == rhs.tz &&
    lhs.tz_offset == rhs.tz_offset &&
    lhs.thumb == rhs.thumb &&
    lhs.thumb_size == rhs.thumb_size &&
    lhs.type == rhs.type
}

public func ==(lhs: RollPhoto, rhs: RollPhoto) -> Bool {
  return (lhs.photo_id == rhs.photo_id &&
    lhs.remote_asset_url == rhs.remote_asset_url &&
    lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.likes == rhs.likes) &&
    (lhs.self_like == rhs.self_like &&
      lhs.taken_at == rhs.taken_at &&
      lhs.taken_by == rhs.taken_by &&
      lhs.is_tip_card == rhs.is_tip_card &&
      lhs.default_image == rhs.default_image &&
      lhs.details == rhs.details)
}

public let rollPhotoFields: [HLDB.Table.Field] =
[ HLDB.Table.Field(name: "photo_id",         type: .Text, index: .Primary, defaultValue: .NonNull),
  HLDB.Table.Field(name: "remote_asset_url", type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "title",            type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "subtitle",         type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "likes",            type: .Integer, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "like_details",     type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "self_like",        type: .Integer, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "taken_at",         type: .Real, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "taken_by",         type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "is_tip_card",      type: .Real, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "default_image",    type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "details",          type: .Text, index: .None, defaultValue: .NonNull),
  HLDB.Table.Field(name: "tags",             type: .Text, index: .None, defaultValue: .NonNull),
]

public class RollReverseGeocode: HLDB.Entity {
  lazy public var City: String        = self.stringValue("City")
  lazy public var Country: String     = self.stringValue("Country")
  lazy public var State: String       = self.stringValue("State")
  lazy public var SubLocality: String = self.stringValue("SubLocality")
  
  override public func toFields() -> [String: AnyObject] {
    return ["City"        : City,
            "Country"     : Country,
            "State"       : State,
            "SubLocality" : SubLocality]
  }
}

public class RollWeather: HLDB.Entity {
  lazy public var cloud_cover: Int = self.intValue("cloud_cover")
  lazy public var humidity: Int     = self.intValue("humidity")
  lazy public var icon: String      = self.stringValue("icon")
  lazy public var summary: String   = self.stringValue("summary")
  lazy public var visibility: Int   = self.intValue("visibility")
  lazy public var wind_bearing: Int = self.intValue("wind_bearing")
  lazy public var wind_speed: Int   = self.intValue("wind_speed")
  
  override public func toFields() -> [String: AnyObject] {
    return ["cloud_cover"  : cloud_cover,
            "humidity"     : humidity,
            "icon"         : icon,
            "summary"      : summary,
            "visibility"   : visibility,
            "wind_bearing" : wind_bearing,
            "wind_speed"   : wind_speed]
  }
}

public class RollLocation: HLDB.Entity {
  lazy public var Lat: Double = self.doubleValue("Lat")
  lazy public var Lng: Double = self.doubleValue("Lng")
  
  override public func toFields() -> [String: AnyObject] {
    return ["Lat" : Lat,
            "Lng" : Lng ]
  }
}

public class RollPhotoDetails: HLDB.Entity {
  lazy public var client_asset_url: String = self.stringValue("client_asset_url")
  lazy public var exif: String             = self.stringValue("exif")
  lazy public var size: Int                = self.intValue("size")
  lazy public var tz: String               = self.stringValue("tz")
  lazy public var tz_offset: Int           = self.intValue("tz_offset")
  lazy public var thumb: Bool              = self.boolValue("thumb")
  lazy public var thumb_size: Int          = self.intValue("thumb_size")
  lazy public var type: String             = self.stringValue("type")
  lazy public var location: RollLocation   = RollLocation(fields: self.dictValue("location"))
  lazy public var weather: RollWeather     = RollWeather(fields: self.dictValue("weather"))
  lazy public var reverse_geocode: RollReverseGeocode = RollReverseGeocode(fields: self.dictValue("reverse_geocode"))
  
  override public func toFields() -> [String: AnyObject] {
    return ["client_asset_url" : client_asset_url,
      "exif"             : exif,
      "size"             : size,
      "tz"               : tz,
      "tz_offset"        : tz_offset,
      "thumb"            : thumb,
      "thumb_size"       : thumb_size,
      "type"             : type,
      "location"         : location.toFields(),
      "weather"          : weather.toFields(),
      "reverse_geocode"  : reverse_geocode.toFields()]
  }
}

public class RollPhotoTagLocation: HLDB.Entity {
  lazy public var fromLeft: Float = self.floatValue("fromLeft")
  lazy public var fromTop: Float  = self.floatValue("fromTop")
  
  override public func toFields() -> [String: AnyObject] {
    return ["fromLeft" : fromLeft,
      "fromTop"  : fromTop]
  }
}

public class RollContact: HLDB.Entity {
  lazy public var id: String = self.stringValue("id")
  lazy public var username: String = self.stringValue("username")
  lazy public var name: String = self.stringValue("name")
  lazy public var info: String = self.stringValue("info")
  lazy public var phone: String = self.stringValue("phone")
  lazy public var email: String = self.stringValue("email")
  lazy public var numFriends: Int = self.intValue("numFriends")
  lazy public var kindStr: String = self.stringValue("kindStr")
  lazy public var inStateStr: String = self.stringValue("inStateStr")
  lazy public var outStateStr: String = self.stringValue("outStateStr")
  
  override public func toFields() -> [String: AnyObject] {
    return ["id"          : id,
      "username"    : username,
      "name"        : name,
      "info"        : info,
      "phone"       : phone,
      "email"       : email,
      "numFriends"  : numFriends,
      "kindStr"     : kindStr,
      "inStateStr"  : inStateStr,
      "outStateStr" : outStateStr]
  }
}

public class RollPhotoTag: HLDB.Entity {
  lazy public var createdBy: String              = self.stringValue("createdBy")
  lazy public var location: RollPhotoTagLocation = RollPhotoTagLocation(fields: self.dictValue("location"))
  lazy public var title: String                  = self.stringValue("title")
  lazy public var createdAt: Float               = self.floatValue("createdAt")
  lazy public var lastUpdatedAt: Float           = self.floatValue("lastUpdatedAt")
  lazy public var photoId:String                 = self.stringValue("photoId")
  lazy public var id: String                     = self.stringValue("id")
  lazy public var canEdit : Bool                 = self.boolValue("canEdit")
  lazy public var contact: RollContact           = RollContact(fields: self.dictValue("contact"))
  
  override public func toFields() -> [String: AnyObject] {
    return ["createdBy"     : createdBy,
            "location"      : location.toFields(),
            "title"         : title,
            "createdAt"     : createdAt,
            "lastUpdatedAt" : lastUpdatedAt,
            "photoId"       : photoId,
            "id"            : id,
            "canEdit"       : canEdit]
  }
}


public class RollLike: HLDB.Entity {
  lazy public var name: String = self.stringValue("name")
  lazy public var ts: Double = self.doubleValue("ts")
  
  override public func toFields() -> [String: AnyObject] {
    return ["name" : name,
            "ts"   : ts]
  }
}

public class RollPhotosPage: HLDB.Entity {
  lazy public var previous: String  = self.stringValue("previous")
  lazy public var next: String      = self.stringValue("next")
  lazy public var page: [RollPhoto] = self.pageValue()
  
  override public func toFields() -> [String: AnyObject] {
    return ["previous" : previous,
            "next"     : next,
            "page"     : pageJSON()]
  }
  
  func pageValue() -> [RollPhoto] {
    if let dictArray = arrayValue("page") as? [[String: AnyObject]] {
      return dictArray.map { RollPhoto(fields: $0) }
    }
    return []
  }
  
  func pageJSON() -> String {
    return serializeToJSON(page.map { $0.toFields() })
  }
}

public class RollPhoto: HLDB.Entity, Equatable {
  lazy public var photo_id: String          = self.stringValue("photo_id")
  lazy public var remote_asset_url: String  = self.stringValue("remote_asset_url")
  lazy public var title: String             = self.stringValue("title")
  lazy public var subtitle: String          = self.stringValue("subtitle")
  lazy public var likes: Int                = self.intValue("likes")
  lazy public var like_details: [RollLike]  = self.likeDetailsValue()
  lazy public var self_like: Bool           = self.boolValue("self_like")
  lazy public var taken_at: Double          = self.doubleValue("taken_at")
  lazy public var taken_by: String          = self.stringValue("taken_by")
  lazy public var is_tip_card: Bool         = self.boolValue("is_tip_card")
  lazy public var default_image: String     = self.stringValue("default_image")
  lazy public var details: RollPhotoDetails = RollPhotoDetails(fields: self.dictValue("details"))
  lazy public var tags: [RollPhotoTag]      = self.tagsValue()
  
  override public func toFields() -> [String: AnyObject] {
    return ["photo_id"         : photo_id,
            "remote_asset_url" : remote_asset_url,
            "title"            : title,
            "subtitle"         : subtitle,
            "likes"            : likes,
            "self_like"        : self_like,
            "like_details"     : likeDetailsJSON(),
            "taken_at"         : taken_at,
            "taken_by"         : taken_by,
            "is_tip_card"      : is_tip_card,
            "default_image"    : default_image,
            "details"          : details.toJSON() ]
  }
  
  func likeDetailsJSON() -> String {
    return serializeToJSON(like_details.map { $0.toFields() })
  }
  
  func likeDetailsValue() -> [RollLike] {
    if let dictArray = arrayValue("like_details") as? [[String: AnyObject]] {
      return dictArray.map { RollLike(fields: $0) }
    }
    return []
  }
  
  func tagsJSON() -> String {
    return serializeToJSON(tags.map { $0.toFields() })
  }
  
  func tagsValue() -> [RollPhotoTag] {
    if let dictArray = arrayValue("tags") as? [[String: AnyObject]] {
      return dictArray.map { RollPhotoTag(fields: $0) }
    }
    return []
  }
}