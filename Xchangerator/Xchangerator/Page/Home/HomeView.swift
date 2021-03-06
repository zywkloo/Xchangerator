//
//  HomeView.swift
//  Xchangerator
//
//  Created by Yizhang Cao on 2020-01-28.
//  Copyright © 2020 YYES. All rights reserved.
//

import Foundation
import PartialSheet
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var stateStore: ReduxRootStateStore
    @State private var baseCurrencyAmt: String = "100"
    @State private var targetCountry: Country = Country()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var modalPresented: Bool = false
    @State private var favourite: Bool = false
    @State private var showLinkTarget = false
    @State private var chartClicked = false
    @State private var setAlertClicked = false
    @State private var conditionOperator = "LT"
    @Binding var selectionFromParent: Int
    @State private var moreThanTwoActiveAlerts = false
    @State private var isDuplicateAlert = false

    private func convert(_ targetCurrencyUnit: String) -> String {
        let amount = Double(baseCurrencyAmt) ?? 0
        let converter = Converter(stateStore.countries)
        let convertedAmount = converter.convert(targetCurrencyUnit, amount)
        return String(format: "%.2f", convertedAmount)
    }

    private func isBaseCurrency(_ name: String) -> Bool {
        return name == stateStore.countries.baseCountry.name
    }

//    private func setBaseCurrency(_ newBase: Country) {
//        self.stateStore.countries.baseCountry = newBase
//    }

//    private func switchBase(_ newBase: Country) {
//        self.favourite = false
//        self.stateStore.setBaseCountry(newBase)
//        Logger.debug(self.stateStore.countries.baseCountry)
//    }

    private func endEditing() {
        UIApplication.shared.endEditing()
    }

    private func isFavorite() -> Bool {
        let currentConversion = FavoriteConversion(baseCurrency: stateStore.countries.baseCountry, targetCurrency: targetCountry)
        do {
            _ = try stateStore.favoriteConversions.find(currentConversion)
            return true
        } catch {
            return false
        }
    }

    private func addToFavorite() -> String {
        let converter = Converter(stateStore.countries)
        if !isFavorite() {
            let newConv = stateStore.favoriteConversions.copy() as! FavoriteConversions
            newConv.add(FavoriteConversion(baseCurrency: stateStore.countries.baseCountry, targetCurrency: targetCountry, rate: converter.getRate(targetCountry.unit, Double(baseCurrencyAmt) ?? 0)))
            stateStore.favoriteConversions = newConv
        }
        return ""
    }

    private func deleteFromFavorite() -> String {
        if isFavorite() {
            do {
                try stateStore.favoriteConversions.delete(FavoriteConversion(baseCurrency: stateStore.countries.baseCountry, targetCurrency: targetCountry))
            } catch {
                Logger.error(error)
            }
        }
        return ""
    }

    private func isInAlerts() -> Bool {
        let converter = Converter(stateStore.countries)
        let currentAlert = MyAlert(baseCurrency: stateStore.countries.baseCountry, targetCurrency: targetCountry, conditionOperator: conditionOperator, rate: converter.getRate(targetCountry.unit, Double(baseCurrencyAmt) ?? 0))
        do {
            _ = try stateStore.alerts.find(currentAlert)
            return true
        } catch {
            return false
        }
    }

//    private func addToAlerts() -> String {
//        let converter = Converter(stateStore.countries)
//        if (!isInAlerts()) {
//            stateStore.alerts.addToFirst(MyAlert(baseCurrency: baseCountry, targetCurrency: targetCountry, conditionOperator: conditionOperator, rate: converter.getRate(targetCountry.unit, Double(baseCurrencyAmt) ?? 0)))
//        }
//        Logger.debug(stateStore.alerts.getModel())
//        return ""
//    }

    private func changeFirstDisabledAlert() {
//        stateStore.alerts.test()
        let converter = Converter(stateStore.countries)

        for index in 0 ... stateStore.alerts.getModel().count - 1 {
            if stateStore.alerts.getModel()[index].disabled {
                stateStore.alerts.changeAlert(index,
                                              MyAlert(baseCurrency: stateStore.countries.baseCountry,
                                                      targetCurrency: targetCountry,
                                                      conditionOperator: conditionOperator,
                                                      rate: converter.getRate(targetCountry.unit,
                                                                              Double(baseCurrencyAmt) ?? 0)))
                break
            }
        }
    }

//    private func checkIfMoreThanTwoActiveAlerts() -> Bool {
//        var count = 0
//
//        for i in 0...stateStore.alerts.getModel().count-1 {
//            if (!stateStore.alerts.getModel()[i].disabled){
//                count += 1
//            }
//        }
//        if (count >= 2){
//            self.moreThanTwoActiveAlerts = true
//        }
//        return self.moreThanTwoActiveAlerts
//    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: screenWidth * 0.05) {
                    VStack(alignment: .leading) {
                        HStack(spacing: screenWidth * 0.05) {
                            Text(self.stateStore.countries.baseCountry.flag)
                                .font(.title)
                                .frame(width: 30, height: 15)
                            TextField("Amount", text: $baseCurrencyAmt)
                                .keyboardType(.decimalPad)
                                .frame(width: screenWidth * 0.3)
                                .multilineTextAlignment(.trailing)
                            Text(self.stateStore.countries.baseCountry.unit)
                                .frame(width: 50)
                                .font(.headline)
                        }.padding(.top, 10)
                        HStack {
                            Text(self.stateStore.countries.baseCountry.name)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .frame(maxWidth: screenWidth * 0.7, alignment: .leading)
                                .fixedSize()
                        }
                    }.padding(.leading, screenWidth * 0.07)
                }
                .padding(.bottom, 5)
                .frame(width: screenWidth * 0.8, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(self.colorScheme == .light ? Color.black : Color.white, lineWidth: 0.5)
                )
                .fixedSize()

                List(stateStore.countries.getModel(), id: \.self) { country in
                    HStack(spacing: screenWidth * 0.06) {
                        VStack(alignment: .leading) {
                            HStack(spacing: screenWidth * 0.05) {
                                Text(country.flag)
                                    .font(.title)
                                    .frame(width: 30, height: 15)
                                    .fixedSize()
                                Text(self.convert(country.unit))
                                    .frame(width: screenWidth * 0.35, alignment: .trailing)
                                    .fixedSize()
                                Text(country.unit)
                                    .frame(width: 50, alignment: .leading)
                                    .font(.headline)
                                    .fixedSize()
                            }
                            HStack {
                                Text(country.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: screenWidth * 0.6, alignment: .leading)
                                    .padding([.bottom, .top], 5)
                                    .fixedSize()
                            }.frame(alignment: .leading)
                        }.padding(.leading, screenWidth * 0.06)
                            .contentShape(Rectangle())
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        self.stateStore.countries.setBaseCountry(country)
                                        self.stateStore.countries = self.stateStore.countries.copy() as! Countries
                                    }
                            )
                        // }
                        Divider()
                        Image(systemName: "ellipsis")
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 30)
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        self.targetCountry = country
                                        self.favourite = self.isFavorite()
                                        self.modalPresented = true
                                    }
                            )
                    }
                    .padding(.top, 10)
                }
            }.navigationBarTitle("Exchange Rates ")

        }.onTapGesture {
            self.endEditing()

        }.partialSheet(
            presented: $modalPresented
        ) {
            // Package: https://github.com/AndreaMiotto/PartialSheet
            ZStack {
                Color.partialSheetBg
//                    .cornerRadius(30)
//                    .padding(.horizontal, 5)

                VStack {
                    Group {
                        Divider().padding(20)
                        Toggle(isOn: self.$favourite) {
                            if self.favourite {
                                Text("\(self.addToFavorite())")
                            } else {
                                Text("\(self.deleteFromFavorite())")
                            }
                            HStack {
                                Image(systemName: "heart")
                                    .font(.title)
                                Text("Add to Favorites")
                                    .padding()
                                    .font(.headline)
                            }.foregroundColor(.black)
                        }.padding(.top, 30)
                            .padding(.horizontal, 30)
                        HStack {
//                            Button(action: {
//                                          do {
//                                            self.chartClicked.toggle()
//                                          }
//                                      }) {
//                                          VStack {
//                                              Image(systemName: "chart.bar")
//                                                  .font(.title)
//                                              Text("Chart")
//                                                  .fontWeight(.semibold)
//                                                  .font(.headline)
//                                          }
//                            }.buttonStyle(GradientBackgroundStyle())
                            Button(action: {
                                do {
                                    self.moreThanTwoActiveAlerts = self.stateStore.alerts.checkIfMoreThanTwoActiveAlerts()
                                    if !self.moreThanTwoActiveAlerts, !self.isInAlerts() {
                                        self.changeFirstDisabledAlert()
                                        self.selectionFromParent = 2
                                        self.setAlertClicked = true
                                    }
                                }
                                      }) {
                                VStack {
                                    Image(systemName: "bell")
                                        .font(.title)
                                    Text("Set Alert")
                                        .fontWeight(.semibold)
                                        .font(.headline)
                                }.alert(isPresented: self.$moreThanTwoActiveAlerts) {
                                    Alert(title: Text("Warning"), message: Text("You cannot add more than two active alerts. Please disable one alert first"), dismissButton: .default(Text("OK")))
                                }
                            }.buttonStyle(GradientBackgroundStyle())
                        }
                        Divider().padding(.bottom, 50)
                    }
                }

            }.frame(height: 200)
                .onAppear(perform: {
                    self.modalPresented = false
                    self.isDuplicateAlert = false
            })
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let themeBlueGreenMixedBold = LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .topLeading, endPoint: .trailing)
    static let partialSheetBg = LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray]), startPoint: .top, endPoint: .bottom)
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ConstantDevices.AlliPhones, id: \.self) { deviceName in ContentView(selection: 0).environmentObject(ReduxRootStateStore()).previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
}

struct GradientBackgroundStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(.white)
//            .background(Color.themeBlueGreenMixedBold)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(10)).stroke(Color.partialSheetBg))
            .padding(20)
//            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}
