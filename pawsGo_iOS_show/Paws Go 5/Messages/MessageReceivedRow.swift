//
//  MessageReceivedRow.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-23.
//

import SwiftUI

struct MessageReceivedRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @State var message : MessageCore
    @State var shouldNavigateSendMessage = false
    @State var sendOrReceive : Bool?
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if self.sendOrReceive == true {
                        Text("From: " + message.senderName!)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .font(.system(size: CONTENT_FONT_SIZE))
                    } else if self.sendOrReceive == false {
                        Text("To: " + message.targetName!)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .font(.system(size: CONTENT_FONT_SIZE))
                    } else {
                        Text("not loaded yet")
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .font(.system(size: CONTENT_FONT_SIZE))
                    }
                    
                    Text(message.date!)
                        //.padding(.top, 5)
                        .padding(.leading, 10)
                        .font(.system(size: CONTENT_FONT_SIZE))
                    Spacer()
                    
                }
                Text(message.messageContent!)
                    //.padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .font(.system(size: CONTENT_FONT_SIZE))
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
            SendMessageView(originalMessage: self.message)
                .environmentObject(firebaseClient)
        }
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        
    }
}

struct MessageReceivedRow_Previews: PreviewProvider {
    static var message = MessageCore()
    
    static var previews: some View {
        MessageReceivedRow(message: message, sendOrReceive: true)
    }
}
