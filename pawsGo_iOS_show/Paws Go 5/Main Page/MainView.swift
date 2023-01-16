//
//  MainView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI
import CoreData

// now, I'll refactor this struct to show the user object in the local database
// I'll never show the user from firebase directly
// whenever I got the user from firebase, I save it in the core data immediately
// I retrieve the from core data and show the user
struct MainView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var moc
    @State private var shouldNavigateReportPet = false
    @State private var shouldNavigatePetsList = false
    @State private var shouldNavigateSendMessageList = false
    // I initialize the fetch request as an instance variable here
    // I init it again when the id string is available, it will do the fetch immediately.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.userID)],
                  predicate: NSPredicate(format: "userName == %@", "Kelly")) var userProfile : FetchedResults<UserCore>
    @State private var userCore : UserCore?
    @State private var shouldNavigateReceiveMessageList = false
    @State private var shouldNavigateChangePassword = false
    //@State private var shouldNavigateSendMessageList = false
    @State private var messageSentOrReceived = true
    @State private var showProgress = false
    @State private var userLostDogs : [DogCore]?
    
    init(id: String) {
        _userProfile = fetchUserRequest(id: id)
    }
    
    var body: some View {
        VStack {
            if !isLandscape {
                VStack {
                    //Spacer()
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(named: "doghouse.png")!)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.top, 50)
                        Spacer()
                    }
                    .padding(.top, 70)
                    HStack {
                        Text("Hello")
                            .padding(.top, 30)
                            .font(.system(size: TITLE_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text("\(userProfile.first?.userName ?? "there")")
                            .padding(.leading, 2)
                            .padding(.top, 30)
                            .font(.system(size: TITLE_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    Image(uiImage: UIImage(named: "worker.png")!)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.top, 30)
                    Text("Email:  \(userProfile.first?.userEmail ?? "still loading...")")
                        .padding(.top, 20)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    HStack {
                        Text("Password: ")
                            .padding(.top, 20)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Button("Change Password") {
                            shouldNavigateChangePassword = true
                        }
                        .padding(.top, 20)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    
                    Button("Logout") {
                        firebaseClient.signOut()
                    }
                    .padding(.top, 30)
                    .font(.system(size: CONTENT_FONT_SIZE))
                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    Spacer()
                } // end of VStack
             
                //} // end of VStack
            } else {
                // landscape
                HStack {
                    Spacer()
                    VStack {
                        Text("Hello")
                            .padding(.top, 120)
                            .font(.system(size: TITLE_FONT_SIZE))
                        Text("\(userProfile.first?.userName ?? "there")")
                            .padding(.leading, 12)
                            //.padding(.top, 2)
                            .font(.system(size: TITLE_FONT_SIZE))
                        Image(uiImage: UIImage(named: "doghouse.png")!)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.top, 20)
                        Spacer()
                    } // section 1
                    VStack {
                        Image(uiImage: UIImage(named: "worker.png")!)
                            .resizable()
                            .frame(width: 120, height: 120)
                            .padding(.top, 30)
                            .padding([.leading, .trailing], 60)
                    } // section 2
                    VStack {
                        Text("Email:  \(userProfile.first?.userEmail ?? "still loading...")")
                            .padding(.top, 20)
                            .font(.system(size: CONTENT_FONT_SIZE))
                        HStack {
                            Text("Password: ")
                                .padding(.top, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                            Button("Change Password") {
                                shouldNavigateChangePassword = true
                            }
                            .padding(.top, 10)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        }
                        Button("Logout") {
                            firebaseClient.signOut()
                        }
                        .padding(.top, 10)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    } // section 3
                    Spacer()
                } // end of HStack
            }// end of if clause
        } // end of VStack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .ignoresSafeArea()
        .navigationBarTitle("Paws Go", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $shouldNavigateReportPet) {
            ReportPet(id: self.firebaseClient.auth.currentUser?.uid ?? "").environmentObject(firebaseClient)
        }
        .navigationDestination(isPresented: $shouldNavigatePetsList) {
            PetsListView(lostOrFound: true)
                .environmentObject(firebaseClient)
        }
        .navigationDestination(isPresented: self.$shouldNavigateChangePassword) {
            ChangePasswordView()
                .environmentObject(firebaseClient)
        }
        .onReceive(firebaseClient.$authState, perform: { state in
            if state == AuthState.LOGGED_OUT {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onReceive(self.firebaseClient.$currentUserFirebase) { user in
            if user != nil {
                print("got current user firebase \(user?.userName)")
                var messages = self.extractMessagesFromUserFirebase(userFirebase: user!)
                var currentUserCore = self.updateLocalUserFromUserFirebase(userFirebase: user!, messagesSent: messages.messagesSent, messagesReceived: messages.messagesReceived, moc: moc)
                //  here we prepare the user's lost dogs list
                // we basically parsed the lost dogs in user object
                // and save to the local database
                self.userLostDogs = []
                self.userLostDogs = self.extractUsersLostDogs(user: user!, moc: self.moc)
                print("userLostDogs size \(self.userLostDogs?.count)")
                
                if self.userLostDogs != nil && self.userLostDogs!.count != 0 {
                    currentUserCore.lostDogs = self.convertUsersLostDogsForUserCore(petCoreList: self.userLostDogs!)
                    //print("userLostDog, dog 1 name \(self.userLostDogs![0].dogName)")
                    //print("userLostDog, dog 2 name \(self.userLostDogs![1].dogName)")
                } else {
                    currentUserCore.lostDogs = [:]
                }
                self.saveContext()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu("Menu") {
                    Button("Report A Pet") {
                        shouldNavigateReportPet = true
                    }
                    Button("Pets List") {
                        Task {
                            let resultTuple = await self.firebaseClient.preparePetsList(moc: moc)
                            // save the dogsCore in local database
                            let lostPets = resultTuple.lostPets
                            let foundPets = resultTuple.foundPets
                            //print("lostPets no: \(lostPets.count)")
                            //print("foundPets no: \(foundPets.count)")
                            self.saveContext()
                            print("saving dogs")
                        }
                        self.shouldNavigatePetsList = true
                    }
                    NavigationLink("Messages Sent") {
                        MessagesListView(true, email: firebaseClient.auth.currentUser?.email! ?? "")
                            .environmentObject(firebaseClient)
                    }.isDetailLink(false)
                    NavigationLink("Messages Received") {
                        MessagesListView(false, email: firebaseClient.auth.currentUser?.email! ?? "")
                            .environmentObject(firebaseClient)
                    }.isDetailLink(false)
                    NavigationLink("Edit Report") {
                        //if self.userLostDogs != nil {
                            //ChooseReport(dogsCore: self.userLostDogs!)
                        ChooseReport(email: self.firebaseClient.auth.currentUser!.email!)
                                .environmentObject(self.firebaseClient)
                               
                        //}
                    }.isDetailLink(false)
                    Button("Logout") {
                        firebaseClient.signOut()
                    }
                }
                .padding([.leading, .trailing], 30)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
            }
        } // end of toolbar
            
    } // end of View
    
    private func fetchUserRequest(id: String) -> FetchRequest<UserCore> {
        print("fetchUserRequest id \(id)")
        let predicate = NSPredicate(format: "userID == %@", id)
        
        let request = NSFetchRequest<UserCore>(entityName: "UserCore")

        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "userName", ascending: true)]
        
        return FetchRequest<UserCore>(fetchRequest: request)
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("saving changes error \(error.localizedDescription)")
        }
    }
    
    private func extractMessagesFromUserFirebase(userFirebase: UserStructFirebase) -> (messagesSent: [MessageCore], messagesReceived: [MessageCore]){
        var messagesSentCore = userFirebase.messagesSent.values.map { messageFirebase in
            convertMessageFirebaseToMessageCore(messageFirebase: messageFirebase, moc: moc)
        }
        var messagesReceivedCore = userFirebase.messagesReceived.values.map { messageFirebase in
            convertMessageFirebaseToMessageCore(messageFirebase: messageFirebase, moc: moc)
        }
        return (messagesSentCore, messagesReceivedCore)
    }
    
    func convertMessageFirebaseToMessageCore(messageFirebase: MessageStructFirebase, moc: NSManagedObjectContext) -> MessageCore {
        
        var messageCore = MessageCore(context: moc)
        messageCore.messageID = messageFirebase.messageID
        messageCore.messageContent = messageFirebase.messageContent
        messageCore.senderName = messageFirebase.senderName
        messageCore.senderEmail = messageFirebase.senderEmail
        messageCore.targetName = messageFirebase.targetName
        messageCore.targetEmail = messageFirebase.targetEmail
        messageCore.date = messageFirebase.date
        
        return messageCore
        
    }
    
    private func createMessagesCoreDict(messagesCore: [MessageCore]) -> [String : MessageCore]{
        var messagesDict : [String : MessageCore] = [:]
        
        messagesCore.map { message in
            messagesDict[message.messageID!] = message
        }
        
        return messagesDict
    }
    
    private func updateLocalUserFromUserFirebase(userFirebase: UserStructFirebase, messagesSent: [MessageCore], messagesReceived: [MessageCore], moc: NSManagedObjectContext) -> UserCore {
        
        var currentUserCore = UserCore(context: moc)
        currentUserCore.userID = userFirebase.userID
        currentUserCore.userName = userFirebase.userName
        currentUserCore.userEmail = userFirebase.userEmail
        currentUserCore.messagesSent = createMessagesCoreDict(messagesCore: messagesSent)
        currentUserCore.messagesReceived = createMessagesCoreDict(messagesCore: messagesReceived)
        currentUserCore.dateCreated = userFirebase.dateCreated
        //currentUserCore.lostDogs = userFirebase.lostDogs
        
        return currentUserCore
    }
    
    private func extractUsersLostDogs(user: UserStructFirebase, moc: NSManagedObjectContext) -> [DogCore] {
        return user.lostDogs.map { key, dog in
            self.createDogCore(moc: moc, id: dog.dogID!, name: dog.dogName, animalType: dog.animalType, breed: dog.dogBreed, gender: dog.dogGender, age: dog.dogAge, place: dog.placeLastSeen, date: dog.dateLastSeen, hour: dog.hour, minute: dog.minute, note: dog.notes, masterID: dog.ownerID, masterName: dog.ownerName, masterEmail: dog.ownerEmail, images: dog.dogImages, lost: dog.lost, found: dog.found, lat: dog.locationLatLng["Lat"], lng: dog.locationLatLng["Lng"], address: dog.locationAddress)
        }
    }
    
    private func convertUsersLostDogsForUserCore(petCoreList: [DogCore]) -> [String : DogCore] {
        var petCoreDict : [String : DogCore] = [:]
        petCoreList.map { petCore in
            petCoreDict[petCore.dogID!] = petCore
        }
        return petCoreDict
    }
    
    private func createDogCore(moc: NSManagedObjectContext, id: String, name: String?, animalType: String?, breed: String?, gender: Int?, age: Int?, place: String?, date: String?, hour: Int?, minute: Int?, note: String?, masterID: String, masterName: String, masterEmail: String, images: [String : String], lost: Bool?, found: Bool?, lat: Double?, lng: Double?, address: String?) -> DogCore {
        
        let dog = DogCore(context: moc)
        dog.dogID = id // get from firebase later
        if name != nil {
            dog.dogName = name
        }
        dog.animalType = animalType
        dog.dogBreed = breed
        //if gender != nil {
        dog.dogGender = Int16(gender!)
        //}
        //var dogAge : Int16?
        if age != nil {
            dog.dogAge = Int16(age!)
        }
        dog.placeLastSeen = place
        dog.dateLastSeen = date
        //var hr : Int16?
        if hour != nil {
            dog.hour = Int16(hour!)
        }
        //var min : Int16?
        if minute != nil {
            dog.minute = Int16(minute!)
        }
        dog.notes = note
        dog.ownerID = masterID
        dog.ownerName = masterName
        dog.ownerEmail = masterEmail
        if lat != nil {
            dog.lat = lat!
        }
        if lng != nil {
            dog.lng = lng!
        }
        if address != nil {
            dog.locationAddress = address!
        }
        dog.dogImages = images
        dog.isLost = lost!
        
        return dog
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static let id = "123"
    
    static var previews: some View {
        let userCore = UserCore(context: moc)
        userCore.userID = "XXX"
        userCore.userName = "Ben"
        userCore.userEmail = "ben@abc.com"
        userCore.dogs = [:]
        userCore.lostDogs = [:]
        userCore.messagesReceived = [:]
        userCore.messagesSent = [:]
        
        return MainView(id: id)
    }
}
