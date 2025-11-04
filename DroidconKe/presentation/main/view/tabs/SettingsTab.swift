//
//  SettingsTab.swift
//  DroidconKe
//
//  Created by @sirodevs on 22/10/2025.
//

import SwiftUI

struct SettingsTab: View {
    @ObservedObject var viewModel: MainViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var conType: ConFilter = .all
    
    var body: some View {
        NavigationStack {
            Form {
                sessionSection
                themeSection
            }
            .background(Color(.surfaceTint))
            .navigationTitle("Settings")
        }
    }
    
    private var sessionSection: some View {
        SettingsSection(header: "Select Session Types") {
            ForEach(ConFilter.allCases) { filter in
                SettingsRow(
                    title: filter.rawValue,
                    foregroundColor: .primary
                ) {
                    viewModel.updateConFilter(filter)
                } trailing: {
                    if viewModel.conFilter == filter {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private var themeSection: some View {
        SettingsSection(header: "Select an App Theme") {
            Picker("Choose Theme", selection: $themeManager.selectedTheme) {
                ForEach(AppThemeMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
