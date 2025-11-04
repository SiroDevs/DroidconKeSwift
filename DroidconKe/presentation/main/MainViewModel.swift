//
//  MainViewModel.swift
//  DroidconKe
//
//  Created by @sirodevs on 20/10/2025.
//

import Foundation

final class MainViewModel: ObservableObject {
    private let prefsRepo: PrefsRepo
    private let netUtils: NetworkUtils
    private let feedRepo: FeedRepoProtocol
    private let organizerRepo: OrganizerRepoProtocol
    private let sessionRepo: SessionRepoProtocol
    private let speakerRepo: SpeakerRepoProtocol
    private let sponsorRepo: SponsorRepoProtocol
    
    @Published var feeds: [FeedEntity] = []
    @Published var organizers: [OrganizerEntity] = []
    @Published var sessions: [SessionEntity] = []
    @Published var speakers: [SpeakerEntity] = []
    @Published var sponsors: [SponsorEntity] = []
    @Published var uiState: UiState = .idle
    @Published var conFilter: ConFilter = .droidcon
    @Published var isConFilterSet: Bool = false

    init(
        prefsRepo: PrefsRepo,
        netUtils: NetworkUtils = .shared,
        feedRepo: FeedRepoProtocol,
        organizerRepo: OrganizerRepoProtocol,
        sessionRepo: SessionRepoProtocol,
        speakerRepo: SpeakerRepoProtocol,
        sponsorRepo: SponsorRepoProtocol
    ) {
        self.prefsRepo = prefsRepo
        self.netUtils = netUtils
        self.feedRepo = feedRepo
        self.organizerRepo = organizerRepo
        self.sessionRepo = sessionRepo
        self.speakerRepo = speakerRepo
        self.sponsorRepo = sponsorRepo
        self.conFilter = prefsRepo.conFilter
        self.isConFilterSet = prefsRepo.isConFilterSet
    }

    func syncData() async {
        if isConFilterSet {
            Task { @MainActor in
                let isOnline = await netUtils.checkNetworkAvailability()
                if isOnline {
                    await fetchRemoteData()
                } else {
                    await fetchLocalData()
                }
            }
        }
    }
    
    func updateConFilterSet() {
        isConFilterSet = true
        Task {
            await MainActor.run { self.prefsRepo.isConFilterSet = true }
        }
    }
    
    func updateConFilter(_ newFilter: ConFilter) {
        conFilter = newFilter
        Task {
            await MainActor.run { self.prefsRepo.conFilter = newFilter }
        }
    }

    @MainActor
    func fetchRemoteData() async {
        uiState = .loading

        do {
            async let organizersTask = organizerRepo.fetchRemoteData()
            async let sessionsTask = sessionRepo.fetchRemoteData(conFilter: conFilter)
            async let sponsorsTask = sponsorRepo.fetchRemoteData(conFilter: conFilter)

            let (remoteOrganizers, remoteSessions, remoteSponsors) = try await (
                organizersTask,
                sessionsTask,
                sponsorsTask
            )

            organizers = remoteOrganizers.sorted { $0.id < $1.id }
            sessions = remoteSessions.sorted { $0.id < $1.id }
            sponsors = remoteSponsors.sorted { $0.id < $1.id }

            try await saveData()

            uiState = .loaded
            print("✅ Data synced successfully.")
        } catch {
            uiState = .error("Failed: \(error.localizedDescription)")

            print("❌ Syncing failed: \(error)")
            if sessions.isEmpty {
                await fetchLocalData()
            }

        }
    }

    private func fetchLocalData() async {
        uiState = .loading
        let localSessions = await Task.detached { self.sessionRepo.fetchLocalData() }.value
        let localSpeakers = await Task.detached { self.speakerRepo.fetchLocalData() }.value

        if !localSessions.isEmpty {
            sessions = localSessions
            speakers = localSpeakers
            uiState = .loaded
        } else {
            print("No sessions found")
        }
    }
    
    private func saveData() async throws {
        await Task.detached {
            self.organizerRepo.saveData(self.organizers)
            self.sessionRepo.saveData(self.sessions)
            self.sponsorRepo.saveData(self.sponsors)
        }.value

        let localSpeakers = await Task.detached { self.speakerRepo.fetchLocalData() }.value
        await MainActor.run {
            speakers = localSpeakers
        }
    }
}
