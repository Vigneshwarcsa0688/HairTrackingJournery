//
//  SettingsView.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("Privacy Policy") { PrivacyPolicyView() }
            NavigationLink("Terms & Conditions") { TermsView() }
            NavigationLink("About Us") { AboutUsView() }
        }
        .navigationTitle("Settings")
    }
}
