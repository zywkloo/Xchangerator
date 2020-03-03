//
//  NotificationView.swift
//  Xchangerator
//
//  Created by Wenyue Deng on 2020-03-02.
//  Copyright © 2020 YYES. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    @State private var turnOnNotification: Bool = false

    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Toggle(isOn: self.$turnOnNotification) {
                    HStack{
                        Text("Turn on Notification")
                            .padding()
                    }.foregroundColor(.black)
                }.padding()
            }.navigationBarTitle("Notification").edgesIgnoringSafeArea(.top)
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
