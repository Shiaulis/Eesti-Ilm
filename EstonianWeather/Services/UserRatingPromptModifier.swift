//
//  UserRatingPromptModifier.swift
//  EstonianWeather
//

import StoreKit
import SwiftUI

private struct UserRatingPromptModifier: ViewModifier {
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase

    let ratingService: UserRatingService
    let promptDelay: Duration

    func body(content: Content) -> some View {
        content
            .task(id: self.scenePhase) {
                guard self.scenePhase == .active else {
                    return
                }

                await self.ratingService.handleAppLaunch(
                    delay: self.promptDelay,
                    requestReview: {
                        self.requestReview()
                    }
                )
            }
    }
}

extension View {
    func userRatingPrompt(
        using ratingService: UserRatingService,
        promptDelay: Duration = UserRatingService.defaultPromptDelay
    ) -> some View {
        self.modifier(
            UserRatingPromptModifier(
                ratingService: ratingService,
                promptDelay: promptDelay
            )
        )
    }
}
