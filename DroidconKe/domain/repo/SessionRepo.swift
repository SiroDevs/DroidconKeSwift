//
//  SessionRepo.swift
//  DroidconKe
//
//  Created by @sirodevs on 19/10/2025.
//

import Foundation

protocol SessionRepoProtocol {
    func fetchRemoteData(conFilter: ConFilter) async throws -> [SessionEntity]
    func fetchLocalData() -> [SessionEntity]
//    func fetchLocalDataBySpeaker() -> [SessionEntity]
    func saveData(_ sessions: [SessionEntity])
    func clearAllData()
}

class SessionRepo: SessionRepoProtocol {
    private let apiService: ApiServiceProtocol
    private let sessionDm: SessionDataManager
    
    init(
        apiService: ApiServiceProtocol,
        sessionDm: SessionDataManager
    ) {
        self.apiService = apiService
        self.sessionDm = sessionDm
    }
    
    func fetchRemoteData(conFilter: ConFilter) async throws -> [SessionEntity] {
        switch conFilter {
            case .all:
                async let droidconTask = fetchDroidconSessions()
                async let flutterconTask = fetchFlutterconSessions()
                
                let (droidconSessions, flutterconSessions) = try await (droidconTask, flutterconTask)
                return droidconSessions + flutterconSessions
                
            case .droidcon:
                return try await fetchDroidconSessions()
                
            case .fluttercon:
                return try await fetchFlutterconSessions()
        }
    }

    private func fetchDroidconSessions() async throws -> [SessionEntity] {
        let response: SessionsRespDTO = try await apiService.fetch(
            endpoint: .sessions(eventSlug: AppSecrets.droidcon_slug)
        )
        
        var droidconSessions: [SessionEntity] = []
        
        for (date, sessions) in response.data {
            let sessionEntities = sessions.map { dto in
                SessionMapper.dtoToEntity(dto, date: date, isDroidcon: true)
            }
            droidconSessions.append(contentsOf: sessionEntities)
        }
        
        return droidconSessions
    }

    private func fetchFlutterconSessions() async throws -> [SessionEntity] {
        let response: SessionsRespDTO = try await apiService.fetch(
            endpoint: .sessions(eventSlug: AppSecrets.fluttercon_slug)
        )
        
        var flutterconSessions: [SessionEntity] = []
        
        for (date, sessions) in response.data {
            let sessionEntities = sessions.map { dto in
                SessionMapper.dtoToEntity(dto, date: date, isDroidcon: false)
            }
            flutterconSessions.append(contentsOf: sessionEntities)
        }
        
        return flutterconSessions
    }

    func fetchLocalData() -> [SessionEntity] {
        let sessions = sessionDm.fetchSessions()
        return sessions.sorted {
            if $0.date == $1.date {
                return $0.startTime < $1.startTime
            }
            return $0.date < $1.date
        }
    }
    
    func saveData(_ sessions: [SessionEntity]) {
        sessionDm.saveSessions(sessions)
    }
    
    func clearAllData() {
        sessionDm.deleteAllSessions()
    }
    
}
