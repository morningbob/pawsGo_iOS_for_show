//
//  MessagesListView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-21.
//

import SwiftUI
import CoreData

struct MessagesListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @State var messages : [MessageCore] = []
    @Environment(\.managedObjectContext) var moc
    
    // this variable is used to distinguish between sent messages list
    // or received messages list.
    // sent - true, received = false
    @State var sendOrReceive : Bool
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]) var messagesCore : FetchedResults<MessageCore>
    
    init(_ sendOrReceive: Bool, email: String) {
        _sendOrReceive = State(initialValue: sendOrReceive)
        _messagesCore = self.fetchMessagesRequest(userEmail: email, send: sendOrReceive)
        print("message list , send set to \(self.sendOrReceive)")
    }
    
    var body: some View {
        
        VStack {
            Image(uiImage: UIImage(named: "chat.png")!)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.top, self.isLandscape ? 40 : 90)
            List(messagesCore, id: \.messageID) { message in
                MessageRow(message: message, sendOrReceive: self.sendOrReceive)
                    .environmentObject(firebaseClient)
                    .listRowBackground(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
                    .border(self.sendOrReceive == true ? .brown : .cyan)
                }
                .padding([.leading, .trailing], self.isLandscape ? 50 : 0)
                
        }
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .navigationBarTitle(self.sendOrReceive ? "Messages Sent List" : "Messages Received List")
        // strange
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND) //.ignoresSafeArea()
            
        }
    }
    
    
    private func fetchMessagesRequest(userEmail: String, send: Bool?) -> FetchRequest<MessageCore> {
        var predicate : NSPredicate?
        
        if self.sendOrReceive == true {
            predicate = NSPredicate(format: "senderEmail = %@", userEmail)
            print("set predicate sender email")
        } else if self.sendOrReceive == false {
            predicate = NSPredicate(format: "targetEmail = %@", userEmail)
            print("set predicate target email")
        } else {
            print("nil predicate")
        }
        
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let fetchRequest = NSFetchRequest<MessageCore>(entityName: "MessageCore")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        //print("returning request")
        return FetchRequest(fetchRequest: fetchRequest)
        
    }
}

struct MessagesListView_Previews: PreviewProvider {
    static var msgs : [MessageCore] = []
    static var sent = true
    static var email = "abc"
    
    static var previews: some View {
        MessagesListView(sent, email: email)
    }
}
