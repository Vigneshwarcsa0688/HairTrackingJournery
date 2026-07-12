//
//  LegalWebView.swift
//  HairJourney
//
//  Created by Mac-24 on 04/02/26.
//

import SwiftUI
import WebKit

struct LegalWebView: UIViewRepresentable {
    let title: String
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
