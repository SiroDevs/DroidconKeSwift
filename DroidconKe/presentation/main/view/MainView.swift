//
//  MainView.swift
//  DroidconKe
//
//  Created by @sirodevs on 19/10/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var selectedTab: Tabbed = .home
    private let prefsRepo: PrefsRepoProtocol
    
    @State private var showOnboarding = false
    
    init() {
        let container = DiContainer.shared
        let prefsRepo = container.resolve(PrefsRepo.self)
        
        self.prefsRepo = prefsRepo
        _viewModel = StateObject(wrappedValue: container.resolve(MainViewModel.self))
        _showOnboarding = State(initialValue: !prefsRepo.isConFilterSet)
    }
    
    var body: some View {
        stateContent
            .edgesIgnoringSafeArea(.bottom)
            .task {
                if prefsRepo.isConFilterSet {
                    await viewModel.syncData()
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView(viewModel: viewModel) {
                    Task {
                        await viewModel.syncData()
                        showOnboarding = false
                    }
                }
                .interactiveDismissDisabled()
            }
            .onChange(of: viewModel.isConFilterSet) { oldValue, newValue in
                showOnboarding = !newValue
        }
    }
    
    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.uiState {
            case .loading:
                LoadingState(fileName: "developerYoga")
                
            case .error(let msg):
                ErrorState(message: msg) {
                    Task {
                        await viewModel.syncData()
                    }
                }
                
            case .loaded:
                TabView(selection: $selectedTab) {
                    HomeTab(viewModel: viewModel, selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(Tabbed.home)
                    
                    FeedTab(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("Feed")
                        }
                        .tag(Tabbed.feed)
                    
                    SessionTab(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Sessions")
                        }
                        .tag(Tabbed.sessions)
                    
                    AboutTab(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "info.circle.fill")
                            Text("About")
                        }
                        .tag(Tabbed.about)
                    
                    SettingsTab(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(Tabbed.settings)
                }
                .accentColor(.blue)
                .environment(\.horizontalSizeClass, .compact)
                
            default:
                EmptyState()
        }
    }
}

enum Tabbed: Int {
    case home = 0
    case feed = 1
    case sessions = 2
    case about = 3
    case settings = 4
}
