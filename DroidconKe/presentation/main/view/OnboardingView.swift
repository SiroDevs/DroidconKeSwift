//
//  OnboardingView.swift
//  DroidconKe
//
//  Created by @sirodevs on 04/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: MainViewModel
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Image(.droidconLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 35)
                    
                    Image(.flutterconkeLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 35)
                    
                    Text("Select your preferred session types to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                }
                .padding(.top, 40)
                
                Form {
                    Section(header: Text("Select Session Types")) {
                        ForEach(ConFilter.allCases) { filter in
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.conFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.updateConFilter(filter)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button("Get Started") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("Welcome! Karibu!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
