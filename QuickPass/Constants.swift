//
//  Constants.swift
//  QuickPass
//
//  Created by Chad Jones on 3/12/21.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleQuickPass = Self("toggleQuickPass")
}

// Access Shared Defaults Object
let userDefaults = UserDefaults.standard

let iconMap = [
    "sql": "\u{e706}",
    "redis": "\u{e76d}",
    "rabbit": "\u{f25b}",
    "think": "\u{fbed}",
    "elastic": "\u{e706}",
    "ceph": "\u{f1b3}",
    "minio": "\u{f1b3}",
    "aws": "\u{e7ad}",
    "amazon": "\u{f270}",
    "vmware": "\u{f233}",
    "confluence": "\u{e75b}",
    "bitbucket": "\u{e703}",
    "jira": "\u{e75c}",
    "slack": "\u{f198}",
    "github": "\u{f09b}",
    "windows": "\u{e70f}",
    "microsoft": "\u{f871}",
    "linux": "\u{e712}",
    "docker": "\u{f308}",
    "digitalocean": "\u{e7ae}",
    "gitlab": "\u{f296}",
    "google": "\u{f1a0}",
    "playstation": "\u{e230}",
    "nintendo": "\u{fcdf}",
    "xbox": "\u{e29d}",
    "steam": "\u{f1b6}",
    "apple": "\u{f179}",
    
]
