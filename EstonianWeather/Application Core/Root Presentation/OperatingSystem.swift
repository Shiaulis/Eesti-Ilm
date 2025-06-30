//
//  OperatingSystem.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 18.06.2022.
//

import Foundation
import SwiftUI

enum OperatingSystem {
    case macOS
    case iOS
    case tvOS
    case watchOS

    #if os(macOS)
    static let current = macOS
    #elseif os(iOS)
    static let current = iOS
    #elseif os(tvOS)
    static let current = tvOS
    #elseif os(watchOS)
    static let current = watchOS
    #else
    #error("Unsupported platform")
    #endif
}

extension View {
    @ViewBuilder
    func ifOS(
        _ operatingSystems: OperatingSystem...,
        modifier: (Self) -> some View
    ) -> some View {
        if operatingSystems.contains(OperatingSystem.current) {
            modifier(self)
        }
        else {
            self
        }
    }
}
