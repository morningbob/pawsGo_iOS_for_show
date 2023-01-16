//
//  EditReport.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2023-01-02.
//

import SwiftUI
import GoogleMaps
import CoreData

// we create a dog object, with the same id
// I display the fields and retrieve all the data in the fields
// but I need to preserve the pet image, if there is one
// don't overwrite it with new dict.
// I make decision to replace the old picture when there is a picture above
// upload picture button
// if pickedImage != nil, create new image dict
// if pickedIamge == nil, we use existing image dict, either it is empty, or it has an image
struct EditReport: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @Environment(\.managedObjectContext) var moc
    //@FetchRequest(sortDescriptors: [SortDescriptor(\.userID)]) var userProfile : FetchedResults<UserCore>
    
    @State var pet : DogCore
    @State private var petName : String = ""
    @State private var petType : String = ""
    @State private var petBreed : String = ""
    @State private var petGender : Int = 0
    @State private var petAge : String = ""
    @State private var lostDate : Date = Date()
    @State private var lostPlace : String = ""
    @State private var lostLat : Double?
    @State private var lostLng : Double?
    @State private var lostTime : Date = Date()
    @State private var lostDateString : String = ""
    @State private var lostTimeString : String = ""
    @State private var hour : Int?
    @State private var minute : Int?
    @State private var notes : String = ""
    let genderChoice = ["Choose", "Male", "Female"]
    @State private var selectedGender = "Choose"
    let petTypeChoice = ["Choose", "Dog", "Cat", "Bird", "Other"]
    @State private var selectedReportType = ""
    // these 3 variables just for lost location view to pass back values
    @State private var latGot : Double?
    @State private var lngGot : Double?
    @State var marker : GMSMarker?
    @State private var shouldReportLocation = 0
    @State private var lostLocationAddress = ""
    @State private var pickedImage : UIImage?
    // this variable has no use in edit view, only useful in report view
    @State private var shouldSendReport : Int = 0
    @State private var showProgress = false
    @State private var currentUser : UserCore?
    @State private var shouldDeleteReport = 0
    
    var body: some View {
        
        ZStack {
            ScrollView {
                if !isLandscape {
                    VStack {
                        Text(self.pet.isLost ? "Lost Report" : "Found Report")
                            .padding(.top, 90)
                            .font(.system(size: TITLE_FONT_SIZE))
                        PetForm(pet: self.pet, petName: self.$petName, petType: self.$petType, petBreed: self.$petBreed, petGender: self.$petGender, petAge: self.$petAge, lostDate: self.$lostDate, lostPlace: self.$lostPlace, lostTime: self.$lostTime, lostDateString: self.$lostDateString, lostTimeString: self.$lostTimeString, hour: self.$hour, minute: self.$minute, notes: self.$notes, latGot: self.$lostLat, lngGot: self.$lngGot, pickedImage: self.$pickedImage, reportOrShow: false, shouldSendReport: self.$shouldSendReport)

                        Button("Delete Report") {
                            confirmDeleteAlert()
                        }
                        .padding(.bottom, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    } // end of enclosing VStack
                } else {
                    // landscape
                    HStack(alignment: .top) {
                        VStack {
                            Text(self.pet.isLost ? "Lost Report" : "Found Report")
                                .padding(.top, 60)
                                .font(.system(size: TITLE_FONT_SIZE))
                            AsyncImage(url: URL(string: (pet.dogImages?.first?.value) ?? ""),
                                       content: { image in
                                image
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .padding(.top, 20)
                                    .scaledToFit()
                            }, placeholder: { Image(uiImage: UIImage(named: "placeholder.png")!)
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .padding(.top, 20)
                                    .scaledToFit()
                            })
                        } // session 1
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 250)
                        .padding(.leading, 60)
                        VStack {
                            PetForm(pet: self.pet, petName: self.$petName, petType: self.$petType, petBreed: self.$petBreed, petGender: self.$petGender, petAge: self.$petAge, lostDate: self.$lostDate, lostPlace: self.$lostPlace, lostTime: self.$lostTime, lostDateString: self.$lostDateString, lostTimeString: self.$lostTimeString, hour: self.$hour, minute: self.$minute, notes: self.$notes, latGot: self.$lostLat, lngGot: self.$lngGot, pickedImage: self.$pickedImage, reportOrShow: false, shouldSendReport: self.$shouldSendReport)
                            Button("Delete Report") {
                                confirmDeleteAlert()
                            }
                            .padding(.bottom, 50)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        }
                    }
                } // end of if clause
            } // end of scroll view
            CustomProgressView(showProgress: self.$showProgress)
        } // end of ZStack
        .onAppear() {
            self.currentUser = self.fetchUser(userID: self.pet.ownerID!, moc: moc)
        }
        .onChange(of: self.pickedImage) { image in
            if image != nil {
                print("got back image")
            }
        }
        .onChange(of: self.latGot) { lat in
            if lat != nil {
                print("got back lat \(lat)")
            }
        }
        .onChange(of: self.shouldSendReport) { should in
            // send to firebase
            if should == 1 {
                self.showProgress = true
                let result = self.processDateTime(date: self.lostDate, time: self.lostTime)
                var hour : Int?
                var minute : Int?
                if result.hour != nil {
                    hour = result.hour
                }
                if result.minute != nil {
                    minute = result.minute
                }
                
                Task {
                    let resultsTuple = await self.firebaseClient.processDogReport(petID: self.pet.dogID, name: self.petName, type: self.petType, breed: self.petBreed, gender: self.petGender, age: Int(petAge), lostPlace: self.lostPlace, lostDate: result.dateString, hour: hour, minute: minute, notes: self.notes, lat: self.latGot, lng: self.lngGot, isLost: self.pet.isLost, isFound: false, image: self.pickedImage, existingImages: self.pet.dogImages)
                    if resultsTuple.result {
                        print("report update success")
                        self.reportSentAlert()
                    } else {
                        self.reportErrorAlert()
                    }
                    self.showProgress = false
                }
            }
        }
        .onChange(of: self.shouldDeleteReport) { should in
            if should == 1 {
                self.cancelReport(dogID: self.pet.dogID!, userID: self.firebaseClient.auth.currentUser!.uid, isLost: self.pet.isLost)
                // reset
                self.shouldDeleteReport = 0
            }
        }
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .ignoresSafeArea()
        .navigationBarTitle("Edit Report")
        
    }
    
    private func processDateTime(date: Date, time: Date) -> (dateString: String, hour: Int?, minute: Int?) {
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy/MM/dd"
        //lostDateString = dateFormatter.string(from: date)
        //print(lostDateString)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        //self.lostTimeString = timeFormatter.string(from: time)
        //print(lostTimeString)
        // extract date and time (hr and minute)
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        print(dateComponents)
        let dateFormatterDateOnly = DateFormatter()
        dateFormatterDateOnly.dateFormat = "yyyy/MM/dd"
        let processedDate = dateFormatterDateOnly.string(from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        print(timeComponents)
        //self.hour = timeComponents.hour
        //self.minute = timeComponents.minute
        
        return (processedDate, timeComponents.hour, timeComponents.minute)
    }
    
    private func fetchUser(userID: String, moc: NSManagedObjectContext) -> UserCore? {
        var userCoreResult : [UserCore] = []
        do {
            let fetchRequest = NSFetchRequest<UserCore>(entityName: "UserCore")
            fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
            
            userCoreResult = try moc.fetch(fetchRequest)
            print("here we may got user back")
            return userCoreResult.first
        } catch {
            print("there is error fetching user \(error.localizedDescription)")
        }
        return nil
    }
    /*
    private func fetchUserRequest(id: String) -> FetchRequest<UserCore> {
        print("fetchUserRequest id \(id)")
        let predicate = NSPredicate(format: "userID == %@", id)
        
        let request = NSFetchRequest<UserCore>(entityName: "UserCore")

        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "userName", ascending: true)]
        
        return FetchRequest<UserCore>(fetchRequest: request)
    }
    */
    private func cancelReport(dogID: String, userID: String, isLost: Bool) {
        Task {
            let result = await self.firebaseClient.deleteReport(dogID: dogID, userID: userID, isLost: isLost)
            if result {
                print("deleting local dog core")
                self.deleteReportLocalDatabase(moc: self.moc)
                if self.currentUser != nil {
                    print("updating user's lost dog")
                    self.currentUser!.lostDogs!.removeValue(forKey: dogID)
                    self.saveContext()
                }
                self.reportDeletedAlert()
            } else {
                self.reportNotDeletedAlert()
            }
        }
    }
    
    private func deleteReportLocalDatabase(moc: NSManagedObjectContext) {
        moc.delete(self.pet)
    }
    
    private func deletePetUserLocal(moc: NSManagedObjectContext) {
        //if firebaseClient
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("saving changes error \(error.localizedDescription)")
        }
    }
    
    private func reportSentAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let invalidAlert = UIAlertController(
            title: "Report Sent",
            message: "The report was sent to the server successfully.  The other users are able to read the details if they search the lost pets menu.  The other users are also able to message you if they saw the dog.", preferredStyle: .alert)
        
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(invalidAlert, animated: true)
    }
    
    private func reportErrorAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let invalidAlert = UIAlertController(
            title: "Report Error",
            message: "There is an error sending the report.  The server may be down.  Please try again later.", preferredStyle: .alert)
        
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(invalidAlert, animated: true)
    }
    
    private func reportDeletedAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let invalidAlert = UIAlertController(
            title: "Delete Report",
            message: "The report was deleted, both in the server and your device.", preferredStyle: .alert)
        
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(invalidAlert, animated: true)
    }
    
    private func reportNotDeletedAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let invalidAlert = UIAlertController(
            title: "Delete Report",
            message: "The report couldn't be deleted.  There is error in the server.  Please try again later.", preferredStyle: .alert)
        
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(invalidAlert, animated: true)
    }
    
    private func confirmDeleteAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let confirmAlert = UIAlertController(
            title: "Delete Report",
            message: "Are you sure to delete the report?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.shouldDeleteReport = 1
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            // do nothing
        })
        
        window.rootViewController?.present(confirmAlert, animated: true)
    }
}
/*
struct EditReport_Previews: PreviewProvider {
    static var previews: some View {
        EditReport()
    }
}
*/
/*
 VStack {
 VStack {
 /*
  Image(uiImage: UIImage(named: "placeholder.png")!)
  .resizable()
  .scaledToFit()
  .frame(width: 200, height: 200)
  .padding(.top, 30)
  */
 AsyncImage(url: URL(string: (pet.dogImages?.first?.value) ?? ""),
 content: { image in
 image
 .resizable()
 .frame(width: 200, height: 200)
 .padding(.top, 30)
 .scaledToFit()
 }, placeholder: { Image(uiImage: UIImage(named: "placeholder.png")!)
 .resizable()
 .frame(width: 200, height: 200)
 .padding(.top, 30)
 .scaledToFit()
 }
 )
 Text("Pet Name")
 .padding(.top, 30)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 TextField(pet.dogName ?? "Unknown", text: self.$petName)
 .font(.system(size: 18))
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 
 HStack {
 Text("Pet Type")
 .padding(.top, 10)
 .padding(.leading, 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 Picker("", selection: self.$selectedType) {
 ForEach(self.petTypeChoice, id:\.self) {
 Text($0)
 }
 }
 .padding(.top, 10)
 .padding(.trailing, 50)
 }
 
 TextField("", text: self.$petType)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 Text("Pet Breed")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 TextField(pet.dogBreed ?? "Unknown", text: self.$petBreed)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 
 }
 VStack {
 HStack {
 Text("Pet Gender")
 .padding(.top, 10)
 .padding(.leading, 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 Picker("", selection: self.$selectedGender) {
 ForEach(self.genderChoice, id:\.self) {
 Text($0)
 }
 }
 .padding(.top, 10)
 .padding(.trailing, 50)
 
 }
 Text("Pet Age")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 TextField(String(pet.dogAge) ?? "Unknown", text: self.$petAge)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 Text("Lost Date")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 // we can't use the textfield hint to show the inputed info
 // we need to put the info in text binding
 TextField("", text: self.$lostDate)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 Text("Lost Time")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 
 Text("Lost Location")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 TextField("", text: self.$lostPlace)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 NavigationLink("Show Location") {
 LostLocationView(userLocationStruct: self.userLocation, latitudeGot: self.$latGot, longitudeGot: self.$lngGot, marker: self.$marker, shouldReportLocation: self.$shouldReportLocation, reportOrShow: true)
 }
 .font(.system(size: 18))
 .padding(.top, 10)
 }
 VStack {
 Text("Notes")
 .padding(.top, 10)
 .padding([.leading, .trailing], 50)
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.system(size: 18))
 TextField("Anything you want to add.", text: self.$notes)
 .padding([.leading, .trailing], 50)
 .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
 Button("Upload Picture") {
 
 }
 .font(.system(size: 18))
 .padding(.top, 10)
 Button("Save") {
 
 }
 .font(.system(size: 18))
 .padding(.top, 10)
 .padding(.bottom, 30)
 
 }
 }// end of enclosing VStack
 .background(Color(red: 0.7725, green: 0.9412, blue: 0.8157))
 .onAppear() {
 self.preprocessPetInfo()
 
 }
 .onChange(of: self.selectedType) { type in
 if type != "Choose" && type != "" {
 self.petType = type
 }
 }
 .onChange(of: self.shouldReportLocation) { should in
 if should == 1 {
 // save that point as latGot and lngGot in pet object
 self.requestAddressGeo()
 }
 }
 
 private func preprocessPetInfo() {
 self.petName = self.extractInfo(info: self.pet.dogName)
 self.petType = self.extractInfo(info: self.pet.animalType)
 self.petBreed = self.extractInfo(info: self.pet.dogBreed)
 self.petAge = self.extractInfo(info: String(self.petAge))
 
 // preprocessing gender
 if pet.dogGender == 1 {
 self.selectedGender = "Male"
 } else if pet.dogGender == 2 {
 self.selectedGender = "Female"
 } else {
 self.selectedGender = "Choose"
 }
 
 self.lostPlace = self.extractInfo(info: self.pet.placeLastSeen)
 //self.lostDate = self.extractInfo(info: self.pet.dateLastSeen)
 //self.lostTime = String(self.pet.hour) + " : " + String(self.pet.minute)
 self.notes = self.extractInfo(info: self.pet.notes)
 
 }
 
 private func extractInfo(info: String?) -> String {
 if info != nil && info != "" {
 return info!
 }
 return "Unknown"
 }
 
 private func requestAddressGeo() {
 if marker != nil {
 GeoHandler.requestAddress(lat: marker!.position.latitude, lng: marker!.position.longitude) { response, error in
 print(response)
 //self.lostLocationAddress = response?.results[0].formatted_address ?? ""
 //self.lostLocation = self.lostLocationAddress
 self.lostPlace = response?.results[0].formatted_address ?? ""
 }
 }
 }
 */
