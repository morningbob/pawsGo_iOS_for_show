//
//  SendMessageView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-21.
//

import SwiftUI
import CoreData

struct SendMessageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @Environment(\.managedObjectContext) var moc
    @State var messageText : String = ""
    @State var originalPet : DogCore?
    @State var originalMessage : MessageCore?
    @State var userName : String?
    // this variable is used to signal the app to display success or failure of sending message
    @State var sendMessageStatus : Int = 0
    @State var showProgress = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if !isLandscape {
                    VStack {
                        Image(uiImage: UIImage(named: "sendmail.png")!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding(.top, 120)
                        
                        Text("Send Message")
                            .padding(.top, 20)
                            .font(.system(size: TITLE_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
                        if userName != nil {
                            Text(userName!)
                                .padding(.top, 20)
                                .font(.system(size: CONTENT_FONT_SIZE))
                        }
                        
                        Text("Please enter the message you want to send: ")
                            .padding(.top, 20)
                            .padding([.leading, .trailing], 50)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
                        TextField("I found your dog...", text: self.$messageText)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 50)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                        
                        Button("Send") {
                            if self.messageText != "" {
                                self.showProgress = true
                                self.processMessage()
                            } else {
                                // alert empty message
                                self.emptyMessageAlert()
                            }
                        }
                        .padding(.top, 40)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Spacer()
                    }
                } else {
                    // landscape
                    HStack {
                        VStack {
                            Text("Send Message")
                                .padding(.top, 30)
                                .font(.system(size: TITLE_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(uiImage: UIImage(named: "sendmail.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .padding(.top, 20)
                            
                        } // session 1
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 200)
                        .padding(.leading, 40)
                        VStack {
                            if userName != nil {
                                Text(userName!)
                                    .padding(.top, 60)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                            
                            Text("Please enter the message you want to send: ")
                                .padding(.top, 20)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            TextField("I found your dog...", text: self.$messageText)
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            
                            Button("Send") {
                                if self.messageText != "" {
                                    self.showProgress = true
                                    self.processMessage()
                                } else {
                                    // alert empty message
                                    self.emptyMessageAlert()
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 40)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        } // session 2
                    }
                } // end of if clause
            } // end of scrollvew
            CustomProgressView(showProgress: self.$showProgress)
        } // end of ZStack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .navigationBarTitle("Send Message")
        .onChange(of: self.sendMessageStatus) { status in
            if status == 1 {
                self.showProgress = false
                // success
                self.successAlert()
            } else if status == 2 {
                self.showProgress = false
                // failed
                self.errorAlert()
            }
            // if status == 0, operation not completed
        }
    }
    
    private func processMessage() {
        // need to get current user's name and email
        // need to get target user name and email
        // validate message
        // there are 2 cases,
        // either user click lost pet and then send message
        // then the pet object is available to pass to send message view
        // or user click message's reply button
        // then, the message object is available
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //formatter.dateStyle = .short
        let date = formatter.string(from: Date())
        
        //if self.messageText != "" {
        if self.firebaseClient.currentUserFirebase != nil {
            let dict = extractTargetNameAndEmail()
            var targetName = dict["name"]
            var targetEmail = dict["email"]
            
            Task {
                if let messageFirebase = (await self.firebaseClient.processSendMessage(messageContent: self.messageText, senderName: firebaseClient.currentUserFirebase!.userName, senderEmail: firebaseClient.currentUserFirebase!.userEmail, receiverName: targetName!, receiverEmail: targetEmail!, date: date) )  {
                
                    self.createAndSaveMessageLocally(messageFirebase: messageFirebase, moc: moc)
                    self.sendMessageStatus = 1
                    self.clearMessage()
               
                } else {
                    self.sendMessageStatus = 2
                }
            }
        } else {
            // alert can't get user's profile, tell user to get online first
            self.errorAlert()
        }
        //} else {
            // alert empty message
        //    self.emptyMessageAlert()
        //}
    }
    
    private func extractTargetNameAndEmail() -> [String : String] {
        var targetName = ""
        var targetEmail = ""
        
        if self.originalPet != nil {
            targetName = self.originalPet!.ownerName!
            targetEmail = self.originalPet!.ownerEmail!
        } else if self.originalMessage != nil {
            targetName = self.originalMessage!.senderName!
            targetEmail = self.originalMessage!.senderEmail!
        } else {
            print("error getting targer name and email")
            return [:]
        }
            
        var dict : [String : String] = [:]
        dict["name"] = targetName
        dict["email"] = targetEmail
        
        return dict
    }
    
    private func clearMessage() {
        self.messageText = ""
    }
    
    private func createAndSaveMessageLocally(messageFirebase: MessageStructFirebase, moc: NSManagedObjectContext) {
        print("creating message core")
        let message = MessageCore(context: moc)
        message.messageID = messageFirebase.messageID
        message.messageContent = messageFirebase.messageContent
        message.senderName = messageFirebase.senderName
        message.senderEmail = messageFirebase.senderEmail
        message.targetName = messageFirebase.targetName
        message.targetEmail = messageFirebase.targetEmail
        message.date = messageFirebase.date
        print("message date: \(message.date)")
        print("saving message core")
        self.saveContext()
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("saving changes error \(error.localizedDescription)")
        }
    }
    
    private func successAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let successAlert = UIAlertController(
            title: "Message Sent",
            message: "The message has been sent successfully.", preferredStyle: .alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(successAlert, animated: true)
    }
    
    private func errorAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Message not Sent",
            message: "There is error sending the message.  Please make sure you have internet access.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
    
    private func emptyMessageAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Message",
            message: "The message is empty.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
}

struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView()
    }
}
