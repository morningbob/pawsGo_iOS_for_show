//
//  MessageRow.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-21.
//

import SwiftUI

struct MessageRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @State var message : MessageCore
    @State var shouldNavigateSendMessage = false
    @State var sendOrReceive : Bool
    @State var userName : String?
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    //VStack {
                        if self.sendOrReceive == true {
                            Text("To: " + message.targetName!)
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if self.sendOrReceive == false {
                            Text("From: " + message.senderName!)
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("not loaded yet")
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                        }
                        
                        Text(message.date!)
                            .padding(.top, 5)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: CONTENT_FONT_SIZE))
                    
                }.frame(width: 80)
                VStack {
                    Text(message.messageContent!)
                    //.padding(.top, 10)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: CONTENT_FONT_SIZE))
                }
            }
            HStack {
                Button("Touch To Reply") {
                    self.shouldNavigateSendMessage = true
                }
                //.padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
                .font(.system(size: CONTENT_FONT_SIZE))
            }
        }
        .navigationDestination(isPresented: self.$shouldNavigateSendMessage) {
            SendMessageView(originalMessage: self.message, userName: self.userName)
                .environmentObject(firebaseClient)
        }
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .onAppear() {
            if self.sendOrReceive {
                self.userName = self.message.targetName
            } else {
                self.userName = self.message.senderName
            }
        }
        
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var message = MessageCore()
    
    static var previews: some View {
        MessageRow(message: message, sendOrReceive: true)
    }
}
