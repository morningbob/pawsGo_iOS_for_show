//
//  FirebaseClient.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import FirebaseStorage
import CoreData

class FirebaseClient : ObservableObject {
    
    var userId : String = ""
    var userName : String = ""
    var userEmail : String = ""
    var userPassword : String = ""
    var userConfirmPassword : String = ""
    var auth = Auth.auth()
    @Published var authListener : AuthStateDidChangeListenerHandle? = nil
    @Published var authState = AuthState.NORMAL
    @Published var appState = AppState.NORMAL
    var firestore = Firestore.firestore()
    @Published var currentUserFirebase : UserStructFirebase?
    var isCreatingAccount = false
    var isSigningIn = false
    private let storage = Storage.storage()
    @Published var downloadUrl : URL?
    @Published var dog : DogStructFirebase?
    //@Published var messagesSent : [MessageFirebase] = []
    //@Published var messagesReceived : [MessageFirebase] = []

    func observeUserState() {
        authListener = auth.addStateDidChangeListener { authObject, user in
            if let user = user {
                self.authState = AuthState.LOGGED_IN
                print("Logged in")
                // when user starts the app, the app keeps the logged in auth
                // we need to retrieve user object from firebase too
                // we can only do it here .  This is the only way to know the
                // user login.
                self.userId = user.uid
                if !self.isSigningIn {
                    self.isSigningIn = false
                    self.retrieveUserFirebase(id: self.userId, completion: { user in
                        print("retrieved user: \(user?.userName)")
                        // we store the user in firebase client
                        self.currentUserFirebase = user
                        // we extract the messages in main view
                      
                    })
                }
            }
            else {
                self.authState = AuthState.LOGGED_OUT
                print("Logged out")
            }
        }
    }
    // there are 2 cases we need to retrieve user object from firebase
    // one is when the user login
    // one is when the user already login previously,
    // the app keeps him logged in
    
    func signUp(email: String, password: String, completion: @escaping(User?) -> Void) {
        
        auth.createUser(withEmail: email.lowercased(), password: password) { result, error in
            guard result != nil && error == nil else {
                print("There is registration error \(error?.localizedDescription)")
                completion(nil)
                return
            }
            print("Sign up success")
            completion(result?.user)
        }
    }
    
    
    func signIn(email: String, password: String, completion: @escaping(User?) -> Void) {
        self.isSigningIn = true
        // make sure email is lowercase,
        // so, we can compare with database in firebase auth
        
        auth.signIn(withEmail: email.lowercased(), password: password) { result, error in
            guard result != nil && error == nil else {
                print("There is signin error \(error?.localizedDescription)")
                completion(nil)
                return
            }
            print("Sign in success")
            completion(result?.user)
        }
    }
    
    
    func signOut() {
        do {
            try auth.signOut()
            print("signed out")
        } catch let error {
            print("sign out failed: \(error.localizedDescription)")
        }
    }
    
    func processSignIn(email: String, password: String) {
        self.signIn(email: email, password: password, completion: { user in
            if user != nil {
                print("sign in success")
                self.userId = user!.uid
                self.retrieveUserFirebase(id: self.userId, completion: { user in
                    print("retrieved user: \(user?.userName)")
                    // we store the user in firebase client
                    self.currentUserFirebase = user
                })
              
            } else {
                // alert user, not correct
                print("sign in failed")
                self.appState = AppState.SIGN_IN_ERROR
            }
        })
    }
    
    func processSignUp(name: String, email: String, password: String) {
        // this variable is used to distinguish between sign in and sign up
        isCreatingAccount = true
        self.signUp(email: email, password: password, completion: { user in
            if user != nil {
                print("sign up success")
                self.userId = user!.uid
                Task {
                    await self.processCreateNewUser(name: name, email: email)
                }
            } else {
                print("sign up failed")
                self.appState = AppState.SIGN_UP_ERROR
            }
        })
    }
    
    func processCreateNewUser(name: String, email: String) async {
        // use current date to create the dateCreated string
        // get yy/MM/dd time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //formatter.dateStyle = .short
        let date = formatter.string(from: Date())
        
        let createdUser = self.createUserFirebase(id: self.userId, name: name, email: email, lost: [:], dog: [:], received: [:], sent: [:], date: date)
        Task {
            let result = await self.saveUserFirebase(user: createdUser)
            
            if result {
                print("created and saved user firebase")
            } else {
                self.appState = AppState.SAVING_ERROR
            }
        }
    }
  
    func createUserFirebase(id: String, name: String, email: String,
                            lost: [String : DogStructFirebase],
                            dog: [String : DogStructFirebase],
                            received: [String : MessageStructFirebase],
                            sent: [String : MessageStructFirebase],
                            date: String
    ) -> UserStructFirebase {
        //let dateCreate = Date.now.formatted(date: .long, time: .shortened)
        
        return UserStructFirebase(userID: id, userName: name, userEmail: email, lostDogs: lost, dogs: dog, dateCreated: date, messagesReceived: received, messagesSent: sent)
    }
    
    func retrieveUserFirebase(id: String, completion: @escaping( (_ userFirebase: UserStructFirebase?) ->  Void)) {
        firestore
            .collection("users")
            .document(id)
            .getDocument() { (document, error) in
                if let error = error {
                    print("There is error : \(error.localizedDescription)")
                    completion(nil)
                } else {
                    //if let document = document, document.exists {
                    if document != nil {
                        print("document is not nil")
                        if document!.exists {
                            print("got back document")
                            let user = try? document?.data(as: UserStructFirebase.self)
                            print("document parsed")
                            print(user)
                            completion(user)
                        } else {
                            print("document not exist")
                        }
                    }
                }
            }
    }
    
    func saveUserFirebase(user: UserStructFirebase) async -> Bool {
        
        print("saving user firebase")
        
        var data = user.dict!
        
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
                firestore
                    .collection("users")
                    .document(user.userID)
                    .setData(data) { error in
                        if let err = error  {
                            print("there is error when saving user \(err.localizedDescription)")
                            continuation.resume(returning: false)
                        } else {
                            print("successfully saved user firebase")
                            continuation.resume(returning: true)
                        }
                    }
            }
        } catch {
            print("error executing unsafe continuation")
            return false
        }
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
    
    // should handle the case when the result is false, maybe repeat the process
    func processDogReport(petID: String?, name: String?, type: String?, breed: String?, gender: Int, age: Int?, lostPlace: String,
                          lostDate: String, hour: Int?, minute: Int?, notes: String?, lat: Double?, lng: Double?, isLost: Bool?, isFound: Bool?, image: UIImage?, existingImages: [String : String]?) async -> (result: Bool, dog: DogStructFirebase?) {
        
        // if petID is not nil, we use the petID to create a pet object ands update
        // if petID is nil, it is a new report, we generate new ID
        
        let id = petID ?? UUID().uuidString
        
        async let url = await self.saveDogImageStorage(image: image, dogID: id)
     
        let dogUrl = await url
        
        var hasImage = false
        if image != nil {
            hasImage = true
        }
        // we check if existingImages == nil or not
        // if it is nil, and image is not nil, we create new dict, and put in new url
        // it it is not nil, we just pass the exisitingImages
        var dogImages : [String : String] = [:]
        if dogUrl != nil {
            // if there is an image url comes back, we put it in the dogImages hashmap
            let key = UUID().uuidString
            dogImages[key] = dogUrl!.absoluteString
            //print("firebase, dogImages, inside if clause: \(dogImages)")
        } else if existingImages != nil {
            // pass the old image dict
            dogImages = existingImages!
        }  // if dogUrl == nil && existingImages == nil
        // we leave the dogImage empty
        
        print("firebase, dogImages, after if clause: \(dogImages)")
        let dog = self.createDogFirebase(id: id, name: name, type: type, breed: breed, gender: gender, age: age, lostPlace: lostPlace, lostDate: lostDate, hour: hour, minute: minute, notes: notes, lat: lat, lng: lng, isLost: isLost, isFound: false, images: dogImages)
 
        // before sending dog report, we need to wait for the download url of the dog image
        // if there is one
        async let sendDogReportSuccess = await self.sendDogReportFirebase(dog: dog)
        async let updateDogUserSuccess = await self.updateDogUserFirebase(user: self.currentUserFirebase, dog: dog)
        
        let results = await [sendDogReportSuccess, updateDogUserSuccess]
        print("send report \(results[0]), update user \(results[1]), download url \(dogUrl?.absoluteString)")
        
        // I return specifically for the success or failure of the operation
        // it is because I can't just report a nil dog object to indicate failure
        // there is a case that there the dogUrl is nil, but the hasImage is true
        // so, in this case, it is also a failure.
        // But is hasImage is false, nil dogUrl is also success
        if results[0] && results[1] && hasImage && dogUrl != nil {
            return (true, dog)
        } else if results[0] && results[1] && !hasImage {
            return (true, dog)
        } else {
            return (false, nil)
        }
    }
    
    // save in Firestore, collection lostDogs
    // can't use FirebaseFirestoreSwift, since the uuid can't be set as a field's key
    func sendDogReportFirebase(dog: DogStructFirebase) async -> Bool {
    //func sendDogReportFirebase(dog: DogStructFirebase, completion: @escaping(Bool) -> Void) {
        // we compose the fields by hand here
        // this is because if I use FirebaseFirestoreSwift, it will add
        print("sending dog report")
        
        var dogsCollection = ""
        //let foundDogsCollection = "foundDogs"
        if dog.lost! {
            dogsCollection = "lostDogs"
        } else {
            dogsCollection = "foundDogs"
        }
        
        let data = dog.dict!
      
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
                self.firestore
                    .collection(dogsCollection)
                    .document(dog.dogID!)
                    .setData(data) { error in
                        if let error = error {
                            print("there is error saving dog report in firebase")
                            continuation.resume(returning: false)
                        } else {
                            print("successfully saved dog report in firebase")
                            continuation.resume(returning: true)
                        }
                    }
            }
        } catch {
            print("error executing unsafe continuation.")
            return false
        }
    }
    
    
    func createDogFirebase(id: String, name: String?, type: String?, breed: String?, gender: Int, age: Int?, lostPlace: String, lostDate: String, hour: Int?, minute: Int?, notes: String?, lat: Double?, lng: Double?, isLost: Bool?, isFound: Bool?, images: [String : String]) -> DogStructFirebase {
        
        // make sure the app has retrieved the user profile
        
        var latLng : [String : Double] = [:]
        latLng["Lat"] = lat
        latLng["Lng"] = lng
      
        return DogStructFirebase(dogID: id, dogName: name, animalType: type, dogBreed: breed, dogGender: gender, dogAge: age, placeLastSeen: lostPlace, dateLastSeen: lostDate, hour: hour, minute: minute, ownerID: currentUserFirebase!.userID, ownerName: currentUserFirebase!.userName, ownerEmail: currentUserFirebase!.userEmail, dogImages: images, lost: isLost, found: isFound, locationLatLng: latLng)
    }
    
    // save image in cloud storage
    // we get back the downloadUrl, the location of the file in the storage
    
    func saveDogImageStorage(image: UIImage?, dogID: String) async -> URL? {
        if image != nil  {
            let storageRef = storage.reference()
            //storageRef.child("lostDogs")
            let dogImageRef = storageRef.child("lostDogs/\(dogID).jpg")
            let jpegData = image!.jpegData(compressionQuality: 1.0)
         
            do {
                return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<URL?, Error>) in
                    let uploadTask = dogImageRef.putData(jpegData!, metadata: nil)  { (metadata, error) in
                        guard let metadata = metadata else {
                            print("error uploading image")
                            continuation.resume(returning: nil)
                            return
                        }
                        print("successfully uploaded image")
                        
                        dogImageRef.downloadURL() { (url, error) in
                            guard let downloadURL = url else {
                                print("error getting url")
                                continuation.resume(returning: nil)
                                return
                            }
                            print("got url \(downloadURL)")
                            //self.downloadUrl = downloadURL
                            continuation.resume(returning: downloadURL)
                        }
                        
                    }
                }
            } catch {
                print("error executing unsave continuation")
                return nil
            }
        } else {
            print("image is nil")
            return nil
        }
    }
    
     
    private func updateDogUserFirebase(user: UserStructFirebase?, dog: DogStructFirebase) async -> Bool {
        //private func updateDogUserFirebase(user: UserStructFirebase?, dog: DogStructFirebase,
                                           //completion: @escaping(Bool) -> Void) {
        print("update dog user firebase")
        //var success = false
        if currentUserFirebase != nil {
            // struct is value type, so, of we want to copy it, just assign to a new variable
            var user = currentUserFirebase
            var dogs : [String : DogStructFirebase]?
            if user!.lostDogs.isEmpty {
                dogs = [:]
            } else {
                dogs = user!.lostDogs
            }
            
            
            dogs![dog.dogID!] = dog
            user!.lostDogs = dogs!
            //print("lost dogs \(user!.lostDogs)")
            let result = await self.saveUserFirebase(user: user!)
            
            if !result {
                self.appState = AppState.SAVING_ERROR
                return false
            } else {
                return true
            }
        } else {
            self.retrieveUserFirebase(id: self.userId, completion: { user in
                print("retrieved user: \(user?.userName)")
                // we store the user in firebase client
                self.currentUserFirebase = user
                //completion(false)
            })
            return false
            
        }
    }
    
    // we retrieve both lost pets and found pets separately.
    // 
    func preparePetsList(moc: NSManagedObjectContext) async -> (lostPets: [DogCore], foundPets: [DogCore]){
        // retrieve the data from firestore
        async let lostPets = await self.retrievePetsList(lostOrFound: true)
        async let foundPets = await self.retrievePetsList(lostOrFound: false)
        
        // convert pets to dog core
        let lostPetsCore = await self.convertDogFirebaseToDogCore(moc: moc, dogsFirebase: lostPets)
        let foundPetsCore = await self.convertDogFirebaseToDogCore(moc: moc, dogsFirebase: foundPets)
        
        // save in local database, this part, I leave it to the view to do it
        return (lostPetsCore, foundPetsCore)
    }
    
    private func retrievePetsList(lostOrFound: Bool) async -> [DogStructFirebase] {
        
        var collectionName = ""
        if lostOrFound {
            collectionName = "lostDogs"
        } else {
            collectionName = "foundDogs"
        }
        
        do {
            let querySnapshot = try await firestore
                .collection(collectionName)
                .getDocuments()
            
            if !querySnapshot.documents.isEmpty {
                print("got back lost pets from firebase \(querySnapshot.documents.count)")
                var pets : [DogStructFirebase] = []
                for petDoc in querySnapshot.documents {
                    let pet = try? petDoc.data(as: DogStructFirebase.self)
                    if pet != nil {
                        pets.append(pet!)
                    }
                }
                print("total pets retrieved for lostOrFound = \(lostOrFound): \(pets.count)")
                return pets
            } else {
                print("lost dogs list is empty")
                //querySnapshot.
            }
        } catch {
            print("error in reaching firebase")
        }
        
        return []
    }
    
    func convertDogFirebaseToDogCore(moc: NSManagedObjectContext, dogsFirebase: [DogStructFirebase]) -> [DogCore] {
        
        let dogsCore = dogsFirebase.map { dogFirebase in
            return createDogCore(moc: moc, id: dogFirebase.dogID!, name: dogFirebase.dogName, animalType: dogFirebase.animalType, breed: dogFirebase.dogBreed, gender: dogFirebase.dogGender, age: dogFirebase.dogAge, place: dogFirebase.placeLastSeen, date: dogFirebase.dateLastSeen, hour: dogFirebase.hour, minute: dogFirebase.minute, note: dogFirebase.notes, masterID: dogFirebase.ownerID, masterName: dogFirebase.ownerName, masterEmail: dogFirebase.ownerEmail, images: dogFirebase.dogImages, lost: dogFirebase.lost, found: dogFirebase.found, lat: dogFirebase.locationLatLng["Lat"], lng: dogFirebase.locationLatLng["Lng"], address: dogFirebase.locationAddress)
        }
        return dogsCore
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
    
    func processSendMessage(messageContent: String, senderName: String, senderEmail: String,
                            receiverName: String, receiverEmail: String, date: String) async -> MessageStructFirebase? {
        
        let message = createSendMessageFirebase(msgContent: messageContent, senderName: senderName, senderEmail: senderEmail, receiverName: receiverName, receiverEmail: receiverEmail, date: date)
        
        //var result = false
        do {
            if try await self.sendMessage(message: message) {
                return message
            }
        } catch {
            print("error sending message \(error.localizedDescription)")
        }
        return nil
        
    }
    
    // I can't check whether there is error in firestore
    private func sendMessage(message: MessageStructFirebase) async throws -> Bool {
        
        var data : [String : String] = [:]
        
        data["date"] = message.date
        data["messageID"] = message.messageID
        data["message"] = message.messageContent
        data["senderEmail"] = message.senderEmail
        data["senderName"] = message.senderName
        data["targetName"] = message.targetName
        data["targetEmail"] = message.targetEmail
        
        
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
            firestore
                .collection("messaging")
                .document(message.messageID)
                .setData(data) { err in
                    if err != nil {
                        print("failed to set data \(err?.localizedDescription)")
                        continuation.resume(throwing: AppError(message: "failed to set data, firestore has error"))
                        return
                    }
                    print("sent message to firestore")
                    continuation.resume(returning: true)
                }
        }
    }
    
    private func createSendMessageFirebase(msgContent: String, senderName: String, senderEmail: String,
                                           receiverName: String, receiverEmail: String, date: String) -> MessageStructFirebase {

        let message = MessageStructFirebase(messageID: UUID().uuidString, senderEmail: senderEmail, senderName: senderName, targetEmail: receiverEmail, targetName: receiverName, messageContent: msgContent, date: date)
        
        return message
    }
    
    func changePassword(currentPassword: String, newPassword: String, email: String) async -> Bool {
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
                self.auth
                    .signIn(withEmail: email, password: currentPassword) { result, error in
                        if let error = error {
                            print("error signing in for updating password \(error.localizedDescription)")
                            continuation.resume(returning: false)
                        } else {
                            print("successfully signed in again for updating password")
                            self.auth.currentUser?.updatePassword(to: newPassword) { error in
                                if let error = error {
                                    print("there is error updating password \(error.localizedDescription)")
                                    continuation.resume(returning: false)
                                } else {
                                    print("successfully updated password")
                                    continuation.resume(returning: true)
                                }
                            }
                        }
                    }
                
            }
        } catch {
            print("error executing unsafe contiuation")
            return false
        }
    }
    
    // I will verify if the email is valid before calling the function
    func processPasswordResetRequest(email: String) async -> Bool {
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
                auth.sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        print("there is error send password reset email \(error.localizedDescription)")
                        continuation.resume(returning: false)
                    } else {
                        print("Successfully sent password reset email")
                        continuation.resume(returning: true)
                    }
                }
            }
        } catch {
            print("failed to execute unsafe continuation")
            return false
        }
    }
    
    func deleteReport(dogID: String, userID: String, isLost: Bool) async -> Bool {
        // delete the report in the lost dogs or found dogs collection
        // delete the report in the user profile in firebase
        // delete the report in local database
        async let collectionResult = await self.deleteReportInCollection(dogID: dogID, isLost: isLost)
        async let updateResult = await self.deleteReportInUserObject(dogID: dogID, userID: userID, isLost: isLost)
        
        let results = await [collectionResult, updateResult]
        
        print("results \(results)")
        return results[0] && results[1]
    }
    
    private func deleteReportInCollection(dogID: String, isLost: Bool) async -> Bool {
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
                var collectionName = ""
                if isLost {
                    collectionName = "lostDogs"
                } else {
                    collectionName = "foundDogs"
                }
                firestore
                    .collection(collectionName)
                    .document(dogID)
                    .getDocument() { querySnapshot, error in
                        if let error = error {
                            print("there is error getting the document to delete \(error.localizedDescription)")
                            continuation.resume(returning: false)
                        } else {
                            if querySnapshot?.exists != nil {
                                querySnapshot?.reference.delete()
                                continuation.resume(returning: true)
                            }
                        }
                    }
            }
        } catch {
            print("error executing unsafe continuation")
            return false
        }
    }
    
    private func retrieveReportInUserObject(dogID: String, userID: String, isLost: Bool) async -> UserStructFirebase? {
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<UserStructFirebase?, Error>) in
                firestore
                    .collection("users")
                    .document(userID)
                    .getDocument() { querySnapshot, error in
                        if let error = error {
                            print("there is error getting the user to delete pet report \(error.localizedDescription)")
                            continuation.resume(returning: nil)
                        } else {
                            if querySnapshot?.exists != nil {
                                var user = try? querySnapshot!.data(as: UserStructFirebase.self)
                                if user != nil {
                                    user!.lostDogs.removeValue(forKey: dogID)
                                    // save the user
                                    continuation.resume(returning: user!)
                                } else {
                                    print("Can't parse the user object")
                                    continuation.resume(returning: nil)
                                }
                                
                            }
                        }
                        
                    }
            }
        } catch {
            print("error executing unsafe continuation")
        }
            
        return nil
    }
    
    private func deleteReportInUserObject(dogID: String, userID: String, isLost: Bool) async -> Bool {
        async let user = await self.retrieveReportInUserObject(dogID: dogID, userID: userID, isLost: isLost)
        
        if var updateUser = await user {
            
            updateUser.lostDogs.removeValue(forKey: dogID)
            
            return await self.saveUserFirebase(user: updateUser)
        } else {
            print("couldn't get report")
        }
        
        return false
    }
    
}

extension Encodable {
    var dict: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
/*
extension Encodable {
    func data(using encoder: JSONEncoder = .init()) throws -> Data { try encoder.encode(self) }
    func string(using encoder: JSONEncoder = .init()) throws -> String { try data(using: encoder).string! }
    func dictionary(using encoder: JSONEncoder = .init(), options: JSONSerialization.ReadingOptions = []) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: try data(using: encoder), options: options) as? [String: Any] ?? [:]
    }
}
        
        do {
            let _ = try firestore
                .collection("users")
                .document(user.userID)
                .setData(data) { (error) in
                    guard error == nil else {
                        print("There is save error \(error?.localizedDescription)")
                        //completion(nil)
                        return
                    }
                    print("successfully saved data.")
                }
                //.setData(user)
                //.addDocument(from: user)
            
        } catch {
            print(error.localizedDescription)
        }
         */


/*
func retrieveUserFirebase(id: String) async {
    let getUserTask = Task { () -> UserStructFirebase? in
        var user : UserStructFirebase?
        try await
        firestore
            .collection("users")
            .document(id)
            .getDocument() { (document, error) in
                if let error = error {
                    print("There is error : \(error.localizedDescription)")
                } else {
                    if let document = document, document.exists {
                        print("got back document")
                        user = try? document.data(as: UserStructFirebase.self)
                        print("document parsed")
                        print(user)
                    }
                }
            }
        return user
    }
    
    var taskResult = await getUserTask.result
    var resultUser : UserStructFirebase?
    switch taskResult {
    case .success(let endResult):
        resultUser = endResult
    case .failure(let error):
        //result = false
        print("error: \(error.localizedDescription)")
    }
    print(resultUser?.userName)
    */
/*
var data : [String : Any] = [:]
//(["dogID" : dog.dogID])
data["dogID"] = dog.dogID
data["dogName"] = dog.dogName
data["animalType"] = dog.animalType
data["dogBreed"] = dog.dogBreed
data["dogGender"] = dog.dogGender
data["dogAge"] = dog.dogAge
data["placeLastSeen"] = dog.placeLastSeen
data["dateLastSeen"] = dog.dateLastSeen
data["hour"] = dog.hour
data["minute"] = dog.minute
data["notes"] = dog.notes
data["ownerID"] = dog.ownerID
data["ownerName"] = dog.ownerName
data["ownerEmail"] = dog.ownerEmail
data["dogImages"] = dog.dogImages
data["isLost"] = dog.isLost
data["isFound"] = dog.isFound
data["locationLatLng"] = dog.locationLatLng
data["locationAddress"] = dog.locationAddress
*/
/*
var data : [String : Any] = [:]
data["userID"] = user.userID
data["userName"] = user.userName
data["userEmail"] = user.userEmail
data["lostDogs"] = user.lostDogs
data["dogs"] = user.dogs
data["dateCreated"] = user.dateCreated
data["messagesReceived"] = user.messagesReceived
data["messagesSent"] = user.messagesSent
*/
