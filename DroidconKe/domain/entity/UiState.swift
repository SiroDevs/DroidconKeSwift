//
//  UiState.swift
//  DroidconKe
//
//  Created by @sirodevs on 20/10/2025.
//

enum UiState: Equatable {
    case idle
    case loading
    case synced
    case filtering
    case filtered
    case loaded
    case liked
    case error(String)
}

enum ConFilter: String, CaseIterable, Identifiable {
    case all = "All Sessions"
    case droidcon = "Droidcon Sessions"
    case fluttercon = "FlutterCon Sessions"
    
    var id: String { rawValue }
}
