//
//  EmailVerificationView.swift
//  GreenJourney
//
//  Created by matteo volpari on 02/11/24.
//

import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: SignUpViewModel
    var body: some View {
        VStack {
            Spacer()
            Text("check your email box and verify your GreenJourney account")
            Spacer()
            Button ("Proceed"){
                viewModel.verifyEmail()
                }
            .fullScreenCover(isPresented: $viewModel.emailVerified) {
                FromToView()
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Spacer()
        }
    }
}
