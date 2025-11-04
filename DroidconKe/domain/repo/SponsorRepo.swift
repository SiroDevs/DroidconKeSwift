//
//  SponsorRepo.swift
//  DroidconKe
//
//  Created by @sirodevs on 19/10/2025.
//

protocol SponsorRepoProtocol {
    func fetchRemoteData(conFilter: ConFilter) async throws -> [SponsorEntity]
    func fetchLocalData() async throws -> [SponsorEntity]
    func saveData(_ sponsors: [SponsorEntity])
    func clearAllData()
}

class SponsorRepo: SponsorRepoProtocol {
    private let apiService: ApiServiceProtocol
    private let sponsorDm: SponsorDataManager
    
    init(
        apiService: ApiServiceProtocol,
        sponsorDm: SponsorDataManager,
    ) {
        self.apiService = apiService
        self.sponsorDm = sponsorDm
    }
    
    func fetchRemoteData(conFilter: ConFilter) async throws -> [SponsorEntity] {
        switch conFilter {
            case .all:
                async let droidconTask = fetchDroidconSponsors()
                async let flutterconTask = fetchFlutterconSponsors()
                
                let (droidconSponsors, flutterconSponsors) = try await (droidconTask, flutterconTask)
                return droidconSponsors + flutterconSponsors
                
            case .droidcon:
                return try await fetchDroidconSponsors()
                
            case .fluttercon:
                return try await fetchFlutterconSponsors()
        }
    }

    private func fetchDroidconSponsors() async throws -> [SponsorEntity] {
        let response: SponsorsRespDTO = try await apiService.fetch(
            endpoint: .sponsors(eventSlug: AppSecrets.droidcon_slug)
        )
        return response.data.map { dto in
            SponsorMapper.dtoToEntity(dto)
        }
    }

    private func fetchFlutterconSponsors() async throws -> [SponsorEntity] {
        let response: SponsorsRespDTO = try await apiService.fetch(
            endpoint: .sponsors(eventSlug: AppSecrets.fluttercon_slug)
        )
        return response.data.map { dto in
            SponsorMapper.dtoToEntity(dto)
        }
    }
    
    func fetchLocalData() -> [SponsorEntity] {
        let sponsors = sponsorDm.fetchSponsors()
        return sponsors.sorted { $0.id < $1.id }
    }
    
    func saveData(_ sponsors: [SponsorEntity]) {
        sponsorDm.saveSponsors(sponsors)
    }
    
    func clearAllData() {
        sponsorDm.deleteAllSponsors()
    }
}
