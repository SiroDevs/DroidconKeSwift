//
//  AppConstants.swift
//  DroidconKe
//
//  Created by @sirodevs on 19/10/2025.
//

import Foundation

struct AppConstants {
    static let appTitle = "DroidconKe"
    static let appCredits = "© Siro Devs"
    
    static let videoUrl = "https://droidcon.co.ke/video/dcke25_report.mp4"
    static let baseUrl = "https://api.droidcon.co.ke/v1"
}

struct PrefConstants {
    static let defaultConFilter = "droidcon"
    static let conFilterSet = "conFilterKey"
    static let conFilter = "conFilterKey"
}

struct AppSecrets {
    static let droidcon_slug: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict["DROIDCON_SLUG"] as? String else {
            fatalError("Missing DROIDCON_SLUG in Secrets.plist")
        }
        return value
    }()

    static let fluttercon_slug: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict["FLUTTERCON_SLUG"] as? String else {
            fatalError("Missing FLUTTERCON_SLUG in Secrets.plist")
        }
        return value
    }()

    static let bearer_token: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict["BEARER_TOKEN"] as? String else {
            fatalError("Missing BEARER_TOKEN in Secrets.plist")
        }
        return value
    }()
}

