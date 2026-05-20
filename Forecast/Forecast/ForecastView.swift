//
//  ForecastView.swift
//  Forecast
//
//  Created by Codex on 5/17/26.
//  Copyright © 2026 Mike Henry. All rights reserved.
//

import SwiftUI
import UIKit

struct ForecastView: View {

    @StateObject private var viewModel = ForecastViewModel()
    @FocusState private var isSearchFocused: Bool
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            ForecastColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    searchField
                    weatherContent
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .task {
            if viewModel.forecast == nil {
                viewModel.loadCurrentLocation()
            }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .tint(ForecastColors.accent)
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Weather")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(ForecastColors.primaryText)

            Spacer()

            Button {
                isSearchFocused = false
                viewModel.loadCurrentLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 48, height: 48)
            }
            .background(ForecastColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityLabel("Use current location")
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ForecastColors.secondaryText)

            ZStack(alignment: .leading) {
                if viewModel.searchText.isEmpty {
                    Text("Search city or address")
                        .foregroundStyle(ForecastColors.secondaryText.opacity(0.78))
                }

                TextField("", text: $viewModel.searchText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .foregroundStyle(ForecastColors.primaryText)
                    .onSubmit {
                        isSearchFocused = false
                        viewModel.search()
                    }
            }

            Button {
                viewModel.clearSearch()
                isSearchFocused = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
            }
            .disabled(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 1)
            .accessibilityLabel("Clear search text")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 54)
        .background(ForecastColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var weatherContent: some View {
        if viewModel.forecast != nil {
            VStack(spacing: 22) {
                Image(systemName: viewModel.weatherIconName)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 118, weight: .regular))
                    .frame(width: 148, height: 116)
                    .foregroundStyle(ForecastColors.primaryText)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(viewModel.temperatureText)
                            .font(.system(size: 92, weight: .thin, design: .rounded))
                            .foregroundStyle(ForecastColors.primaryText)
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)

                        Text("°\(viewModel.unitText)")
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(ForecastColors.accent)
                    }
                    .frame(maxWidth: .infinity)

                    Text(viewModel.summaryText)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(ForecastColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(viewModel.locationName.isEmpty ? "Current Location" : viewModel.locationName)
                        .font(.headline)
                        .foregroundStyle(ForecastColors.accent)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                }

                UnitToggle(selectedUnit: $viewModel.selectedUnit)

                HStack(spacing: 12) {
                    MetricView(
                        iconName: "drop.fill",
                        title: "Rain",
                        value: viewModel.precipitationText
                    )

                    MetricView(
                        iconName: "wind",
                        title: "Wind",
                        value: viewModel.windText
                    )
                }

                attributionLink
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
            .background(ForecastColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            loadingContent
        }
    }

    private var attributionLink: some View {
        Button {
            if let url = viewModel.attributionURL {
                openURL(url)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cloud.sun.fill")
                    .accessibilityHidden(true)

                Text(viewModel.providerName)

                Text("Legal Attribution")
                    .underline()
            }
            .font(.footnote.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(ForecastColors.secondaryText)
        .accessibilityLabel("Apple Weather legal attribution")
        .accessibilityHint("Opens the Apple Weather legal attribution page")
        .disabled(viewModel.attributionURL == nil)
        .padding(.top, 2)
    }

    private var loadingContent: some View {
        VStack(spacing: 18) {
            ProgressView()
                .tint(ForecastColors.accent)

            Text(viewModel.isLoading ? "Loading Weather" : "Weather")
                .font(.headline)
                .foregroundStyle(ForecastColors.primaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 360)
        .background(ForecastColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MetricView: View {

    let iconName: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(ForecastColors.warmAccent)
                .frame(height: 26)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(ForecastColors.secondaryText)

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(ForecastColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 104)
        .padding(.horizontal, 10)
    }
}

private struct UnitToggle: View {

    @Binding var selectedUnit: ForecastViewModel.UnitType

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ForecastViewModel.UnitType.allCases) { unit in
                Button {
                    selectedUnit = unit
                } label: {
                    Text("°\(unit.rawValue)")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(selectedUnit == unit ? ForecastColors.selectedControlText : ForecastColors.secondaryText)
                        .frame(width: 68, height: 34)
                        .background {
                            if selectedUnit == unit {
                                Capsule(style: .continuous)
                                    .fill(ForecastColors.selectedControl)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedUnit == unit ? .isSelected : [])
            }
        }
        .padding(4)
        .background(ForecastColors.controlTrack)
        .clipShape(Capsule(style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

private enum ForecastColors {
    static let background = adaptiveColor(
        light: UIColor(red: 7 / 255, green: 91 / 255, blue: 167 / 255, alpha: 1),
        dark: UIColor(red: 3 / 255, green: 34 / 255, blue: 65 / 255, alpha: 1)
    )
    static let surface = adaptiveColor(
        light: UIColor(red: 10 / 255, green: 104 / 255, blue: 185 / 255, alpha: 1),
        dark: UIColor(red: 5 / 255, green: 51 / 255, blue: 95 / 255, alpha: 1)
    )
    static let primaryText = adaptiveColor(
        light: UIColor(red: 0.96, green: 0.99, blue: 0.97, alpha: 1),
        dark: UIColor(red: 0.94, green: 0.98, blue: 1.0, alpha: 1)
    )
    static let secondaryText = adaptiveColor(
        light: UIColor(red: 177 / 255, green: 219 / 255, blue: 1.0, alpha: 1),
        dark: UIColor(red: 139 / 255, green: 191 / 255, blue: 235 / 255, alpha: 1)
    )
    static let accent = adaptiveColor(
        light: UIColor(red: 83 / 255, green: 167 / 255, blue: 243 / 255, alpha: 1),
        dark: UIColor(red: 116 / 255, green: 190 / 255, blue: 1.0, alpha: 1)
    )
    static let warmAccent = adaptiveColor(
        light: UIColor(red: 1.0, green: 0.78, blue: 0.33, alpha: 1),
        dark: UIColor(red: 1.0, green: 0.83, blue: 0.43, alpha: 1)
    )
    static let controlTrack = adaptiveColor(
        light: UIColor(red: 5 / 255, green: 77 / 255, blue: 145 / 255, alpha: 1),
        dark: UIColor(red: 2 / 255, green: 27 / 255, blue: 51 / 255, alpha: 1)
    )
    static let selectedControl = adaptiveColor(
        light: UIColor(red: 235 / 255, green: 247 / 255, blue: 1.0, alpha: 1),
        dark: UIColor(red: 116 / 255, green: 190 / 255, blue: 1.0, alpha: 1)
    )
    static let selectedControlText = adaptiveColor(
        light: UIColor(red: 7 / 255, green: 91 / 255, blue: 167 / 255, alpha: 1),
        dark: UIColor(red: 2 / 255, green: 27 / 255, blue: 51 / 255, alpha: 1)
    )

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}

#Preview {
    ForecastView()
}
