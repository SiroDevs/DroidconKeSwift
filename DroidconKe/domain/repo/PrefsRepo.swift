//
//  PrefsRepo.swift
//  DroidconKe
//
//  Created by @sirodevs on 19/10/2025.
//

import Foundation

protocol PrefsRepoProtocol {
    var isConFilterSet: Bool { get set }
    var conFilter: ConFilter { get set }
    func resetPrefs()
}

class PrefsRepo: PrefsRepoProtocol {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var isConFilterSet: Bool {
        get { userDefaults.bool(forKey: PrefConstants.conFilterSet) }
        set { userDefaults.set(newValue, forKey: PrefConstants.conFilterSet) }
    }
    
    var conFilter: ConFilter {
        get { ConFilter(rawValue: userDefaults.string(forKey: PrefConstants.conFilter) ?? PrefConstants.defaultConFilter) ?? .droidcon }
        set { userDefaults.set(newValue, forKey: PrefConstants.conFilter) }
    }
    
    func setConFilter(_ filter: ConFilter) {
        userDefaults.set(filter.rawValue, forKey: PrefConstants.conFilter)
        userDefaults.set(true, forKey: PrefConstants.conFilterSet)
    }
    
    func resetPrefs() {
        userDefaults.removeObject(forKey: PrefConstants.conFilter)
        userDefaults.removeObject(forKey: PrefConstants.conFilterSet)
    }
}
