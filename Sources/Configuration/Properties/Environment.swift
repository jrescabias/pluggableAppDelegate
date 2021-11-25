//
//  Environment.swift
//  PluggableAppDelegate
//
//

import Foundation

struct Environment {
    static func getValue(forKey key: EnvironmentProperties) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String
    }
}

extension Environment {
    enum EnvironmentProperties: String {
        case appName = "CFBundleName"
        case bundleIdentifier = "CFBundleIdentifier"
        case versionNumber = "CFBundleShortVersionString"
        case buildNumber = "CFBundleVersion"
    }
}
