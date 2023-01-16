//
//  ReportPet.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI
import GoogleMaps
import Photos
import CoreData

struct ReportPet: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.userID)]) var userProfile : FetchedResults<UserCore>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dogID)]) var dogs : FetchedResults<DogCore>
    // this location is just a default, it will be overrided in lost location view, by the
    // location manager
    // however, in pet detail view, the location passes to lost location view is the actual one
    // it won't be overrided by the location manager
    @State var userLocation : LocationStruct = LocationStruct(name: "Here", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    
    @State var petName = ""
    @State var petType = ""
    let petTypeChoice = ["Choose", "Dog", "Cat", "Bird", "Other"]
    //@State var selectedReportType = "Choose"
    @State var petBreed = ""
    @State var petGender = 0
    let genderChoice = ["Choose", "Male", "Female"]
    //@State var selectedGender = "Choose"
    @State var petAge = ""
    @State var lostLocation = ""
    @State var shouldNavigateMap = false
    //@State var selectedTime = ""
    @State var latitudeGot : Double?
    @State var longitudeGot : Double?
    @State var marker : GMSMarker?
    @State var lostLocationAddress = ""
    @State var shouldReportLocation = 0
    @State var lostDate = Date()
    @State var lostTime = Date()
    @State var lostDateString = ""
    @State var lostTimeString = ""
    @State var notes = ""
    @State var pickedImage : UIImage?
    @State var showImagePicker = false
    @State var imageUrl : URL?
    @State private var hour : Int?
    @State private var minute : Int?
    @State private var showLostDate = false
    @State private var reportSent = 0
    @State private var dogCore : DogCore?
    @State private var showProgress = false
    @State private var dogFirebase : DogStructFirebase?
    @State private var selectedReportType = ""
    @State private var shouldSendReport = 0
    let reportChoice = ["Choose", "Lost", "Found"]
    let lostIntro = "Please fill in the form for your lost pet. We\'ll store the data in the database. If anyone found the pet, we\'ll send an email to you. If the other users want to search for lost pets, the pet\'s data will be listed to the users."
    let foundIntro = "Please fill in the form. We\'ll match lost pet\' information with the data here. If we found a match, we\'ll email you and the owner."
    
    
    @State private var reportIntro = "Please choose to report lost or report found"
    
    
    init(id: String) {
        _userProfile = fetchUserRequest(id: id)
    }
    
    var body: some View {
        
        ZStack {
            ScrollView {
                if !isLandscape {
                    VStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Report a pet")
                                    .font(.system(size: TITLE_FONT_SIZE))
                                    .padding(.top, 20)
                                    .bold()
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                            }
                            .padding(.top, 120)
                            Image(uiImage: UIImage(named: "police.png")!)
                                .resizable()
                                .padding(.top, 20)
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            HStack {
                                Text("Lost or Found")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: TITLE_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Picker("Choose", selection: self.$selectedReportType) {
                                    ForEach(self.reportChoice, id:\.self) {
                                        Text($0)
                                            
                                    }
                                }
                                .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                
                            }
                            .font(.system(size: TITLE_FONT_SIZE))
                            .frame(alignment: .leading)
                            .padding([.leading, .trailing], 80)
                            .padding(.top, 20)
                            .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
                            
                            Text(self.$reportIntro.wrappedValue)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .padding(.top, 15)
                                .padding([.leading, .trailing], 50)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            PetForm(petName: self.$petName, petType: self.$petType, petBreed: self.$petBreed, petGender: self.$petGender, petAge: self.$petAge, lostDate: self.$lostDate, lostPlace: self.$lostLocation, lostTime: self.$lostTime, lostDateString: self.$lostDateString, lostTimeString: self.$lostTimeString, hour: self.$hour, minute: self.$minute, notes: self.$notes, latGot: self.$latitudeGot, lngGot: self.$longitudeGot, pickedImage: self.$pickedImage, reportOrShow: true, shouldSendReport: self.$shouldSendReport)
                            Spacer()
                        } // end of enclosing VStack
                    } // end of VStack
               } else {
                    // landscape
                   HStack(alignment: .top) {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Report a pet")
                                    .font(.system(size: TITLE_FONT_SIZE))
                                    .padding(.top, 50)
                                    .bold()
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                            }
                            Image(uiImage: UIImage(named: "police.png")!)
                                .resizable()
                                .padding(.top, 20)
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            HStack {
                                Text("Lost or Found")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: TITLE_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Picker("Choose", selection: self.$selectedReportType) {
                                    ForEach(self.reportChoice, id:\.self) {
                                        Text($0)
                                    }
                                }
                                .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            }
                            .font(.system(size: TITLE_FONT_SIZE))
                            .frame(alignment: .leading)
                            .padding([.leading, .trailing], 30)
                            .padding(.top, 20)
                            HStack {
                                Text(self.$reportIntro.wrappedValue)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .padding(.top, 15)
                                    .padding([.leading, .trailing], 30)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    //.fixedSize(horizontal: true, vertical: false)
                                //.frame(maxWidth: 330)
                            }
                        } // section 1
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 330)
                        VStack {
                            PetForm(petName: self.$petName, petType: self.$petType, petBreed: self.$petBreed, petGender: self.$petGender, petAge: self.$petAge, lostDate: self.$lostDate, lostPlace: self.$lostLocation, lostTime: self.$lostTime, lostDateString: self.$lostDateString, lostTimeString: self.$lostTimeString, hour: self.$hour, minute: self.$minute, notes: self.$notes, latGot: self.$latitudeGot, lngGot: self.$longitudeGot, pickedImage: self.$pickedImage, reportOrShow: true, shouldSendReport: self.$shouldSendReport)
                        } // section 2
                    }
                }// end of if clause
            } // end of scroll view
            .navigationBarTitle("Paws Go")
            .onChange(of: self.reportSent) { sent in
                if sent == 1 {
                    self.showProgress = false
                    self.reportSentAlert()
                    // we create the dog core here when we know that the report is sent
                    print("creating dog core")
                    //print(self.dogFirebase!.dogImages.first?.value)
                    //print("dog name \(self.dogFirebase!.dogName)")
                    self.dogCore = self.createDogCore(id: self.dogFirebase!.dogID!, name: self.dogFirebase!.dogName, animalType: self.dogFirebase!.animalType, breed: self.dogFirebase!.dogBreed, gender: self.dogFirebase!.dogGender, age: self.dogFirebase!.dogAge, place: self.dogFirebase!.placeLastSeen, date: self.dogFirebase!.dateLastSeen, hour: self.dogFirebase!.hour, minute: self.dogFirebase!.minute, note: self.dogFirebase!.notes, masterID: self.dogFirebase!.ownerID, masterName: self.dogFirebase!.ownerName, masterEmail: self.dogFirebase!.ownerEmail, images: self.dogFirebase!.dogImages, lost: self.dogFirebase!.lost, found: self.dogFirebase!.found, lat: self.dogFirebase!.locationLatLng["Lat"], lng: self.dogFirebase!.locationLatLng["Lng"], address: self.dogFirebase!.locationAddress)
                    print("result dog core: \(dogCore)")
                    self.saveContext()
                    //self.clearForm()
                }
            }
            .onChange(of: self.selectedReportType) { report in
                if report == "Found" {
                    self.reportIntro = self.foundIntro
                } else {
                    // this includes the case "Lost" or the case the user didn't choose
                    self.reportIntro = self.lostIntro
                }
            }
            .onChange(of: self.shouldSendReport) { should in
                if should == 1 {
                    self.processPetInfo()
                    // that we need to show progress bar
                    self.showProgress = true
                }
            }
            CustomProgressView(showProgress: self.$showProgress)
        } // end of ZStack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .ignoresSafeArea()
    } // end of view
    
    // we got back all pet info from the fields in the pet form
    // they are passed through the binding variables
    private func processPetInfo() {
        print("processing pet info entered")
        // preprocess gender and age
        /*
        var gender = 0
        if self.petGender == "Male" {
            gender = 1
        } else if self.petGender == "Female" {
            gender = 2
        }
         */
        var age = 0
        if self.petAge != nil && self.petAge != "" && self.petAge != "0"{
            if let ageBack = Int(self.petAge) {
                age = ageBack
            }
        }
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
            let resultsTuple = await self.firebaseClient.processDogReport(petID: nil, name: self.petName, type: self.petType, breed: self.petBreed, gender: self.petGender, age: age, lostPlace: self.lostLocation, lostDate: result.dateString, hour: hour, minute: minute, notes: self.notes, lat: self.latitudeGot, lng: self.longitudeGot, isLost: self.selectedReportType != "Found" ? true : false, isFound: false, image: self.pickedImage, existingImages: nil)
            if resultsTuple.result {
                print("report success")
                self.dogFirebase = resultsTuple.dog
                self.reportSentAlert()
                // notify the app to create pet core locally
                self.reportSent = 1
            } else {
                self.reportErrorAlert()
                self.reportSent = 0
            }
            self.showProgress = false
        }
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
    
    private func clearForm() {
        self.petName = ""
        self.petBreed = ""
        self.petGender = 0
        self.petAge = ""
        self.lostLocation = ""
        self.lostDate = Date()
        self.lostTime = Date()
        self.lostDateString = ""
        self.lostTimeString = ""
        self.notes = ""
        self.pickedImage = nil
        //self.reportSent = 0
        self.petType = ""
        //self.selectedGender = "Choose"
        //self.selectedType = "Choose"
        self.reportIntro = "Please choose to report lost or report found"
        
    }
    
        private func fieldsInvalidAlert() {
            
            guard let window = UIApplication.shared.keyWindow else {
                return }
            
            let invalidAlert = UIAlertController(
                title: "Invalid Fields",
                message: "The pet's name, the lost location and the date of lost are required.", preferredStyle: .alert)
            
            invalidAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                //print("confirmed")
            })
            
            window.rootViewController?.present(invalidAlert, animated: true)
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
        
    private func fetchUserRequest(id: String) -> FetchRequest<UserCore> {
        let predicate = NSPredicate(format: "userID == %@", id)
        
        let request = NSFetchRequest<UserCore>(entityName: "UserCore")
        
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "userName", ascending: true)]
        
        return FetchRequest<UserCore>(fetchRequest: request)
    }
    
    
    private func createDogCore(id: String, name: String?, animalType: String?, breed: String?, gender: Int, age: Int?, place: String?, date: String?, hour: Int?, minute: Int?, note: String?, masterID: String, masterName: String, masterEmail: String, images: [String : String], lost: Bool?, found: Bool?, lat: Double?, lng: Double?, address: String?) -> DogCore {
        
        let dog = DogCore(context: moc)
        dog.dogID = id // get from firebase later
        if name != nil {
            dog.dogName = name
        }
        dog.animalType = animalType
        dog.dogBreed = breed
        //if gender != nil {
        dog.dogGender = Int16(gender)
        //}
        
        if age != nil {
            dog.dogAge = Int16(age!)
        }
        dog.placeLastSeen = place
        dog.dateLastSeen = date
        
        if hour != nil {
            dog.hour = Int16(hour!)
        }
        
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
        //print("when creating dog core: dogImages: \(dog.dogImages)")
        dog.isLost = lost!
        
        return dog
        
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("saving changes error \(error.localizedDescription)")
        }
    }
        
        /*
         switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
         case .notDetermined:
         // ask for access
         case .restricted, .denied:
         // sorry
         case .authorized:
         // we have full access
         
         // new option:
         case .limited:
         // we only got access to some photos of library
         }
         */
    }
    
    struct ReportPet_Previews: PreviewProvider {
        static var id = "123"
        
        static var previews: some View {
            ReportPet(id: id)
        }
    }
    
    // can observe change of state variables
    /*
     extension Binding {
     func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
     Binding(
     get: { self.wrappedValue },
     set: { newValue in
     self.wrappedValue = newValue
     handler(newValue)
     }
     )
     }
     }
     */
    /*
     extension Date {
     func getFormattedDate(format: String) -> String {
     let dateformat = DateFormatter()
     dateformat.dateFormat = format
     return dateformat.string(from: self)
     }
     }
     */
    /*
     let lostBinding = Binding(
     get: {self.shouldReportLocation},
     set: {
     self.shouldReportLocation = $0
     print("should is set: \($0)")
     
     if $0 == 1 {
     print("lost binding detected changes of should")
     }
     }
     )
     */
    /*
    Text("Pet Name")
        .padding(.top, 20)
        .padding([.leading, .trailing], 50)
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(self.showNameError == true ? Color.red : Color.black)
    TextField("Rocky", text: $petName)
    //.padding(.top, 10)
        .padding(.leading, 50)
        .font(.system(size: 18))
    //.foregroundColor(Color.blue)
        .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
    HStack {
        Text("Pet Type")
        
            .frame(maxWidth: .infinity, alignment: .leading)
        Picker("Choose", selection: self.$selectedType) {
            ForEach(self.petTypeChoice, id:\.self) {
                Text($0)
            }
        }
    }
    .font(.system(size: 18))
    .frame(alignment: .leading)
    .padding(.leading, 50)
    .padding(.trailing, 90)
    TextField("Enter the type here if it is not in the list", text: self.$typeInputed) {
        if self.typeInputed != "" {
            print("inputed \(self.typeInputed)")
        }
    }
    .padding([.leading, .trailing], 50)
    .font(.system(size: 18))
    .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
    
    Text("Pet Breed")
        .padding(.top, 20)
        .padding(.leading, 50)
        .padding(.trailing, 100)
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
    TextField("Shiba Inu", text: $petBreed)
    //.padding(.top, 10)
        .padding(.leading, 50)
        .font(.system(size: 18))
        .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
}

HStack {
    Text("Pet Gender")
        .frame(maxWidth: .infinity, alignment: .leading)
    Picker("Male", selection: $selectedGender) {
        ForEach(genderChoice, id:\.self) {
            Text($0)
        }
    }
    //.padding(.top, 20)
    //.padding([.leading, .trailing], 50)
}
.font(.system(size: 18))
//.background(Color(red: 0.5176, green: 0.9490, blue: 0.5961))
.background(Color(red: 0.7725, green: 0.9412, blue: 0.8157))
.frame(alignment: .leading)
.padding(.leading, 50)
.padding(.trailing, 90)

VStack {
    Text("Pet Age")
        .padding(.top, 10)
        .padding([.leading, .trailing], 50)
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
    TextField("2", text: $petAge)
    //.padding(.top, 10)
        .padding(.leading, 50)
        .font(.system(size: 18))
        .keyboardType(.numberPad)
        .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
    Text("Lost Location")
        .padding(.top, 20)
        .padding([.leading, .trailing], 50)
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(self.showLocationError == true ? Color.red : Color.black)
    TextField("Scarborough", text: $lostLocation)
        .padding(.top, 10)
        .padding(.leading, 50)
        .font(.system(size: 18))
        .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
    Button("Show Map") {
        // we reset should report location here
        // so, whenever user clicks show map,
        // the request will be sent for new location
        shouldReportLocation = 0
        shouldNavigateMap = true
    }
    .padding(.top, 10)
    
    //ProgressView()
    //    .opacity(showProgress ? 1 : 0)
    //HStack {
    DatePicker(
        "Lost Date",
        selection: $lostDate,
        in: dateRange,
        displayedComponents: [.date]
    )
    .padding(.top, 20)
    .padding(.leading, 50)
    .padding(.trailing, 100)
    .onChange(of: self.lostDate, perform: { value in
        print(value)
        print("date is set")
        self.dateChanged = true
    })
    .foregroundColor(self.showDateError == true ? Color.red : Color.black)
    
    DatePicker("Lost Time", selection: self.$lostTime, displayedComponents: [.hourAndMinute])
        .padding(.top, 10)
        .padding(.leading, 50)
        .padding(.trailing, 100)
        .onChange(of: self.lostDate, perform: { value in
            print(value)
            print("time is set")
            self.timeChanged = true
        })
    //}
    /*
     TextField(text: self.$lostDateString) {
     
     }
     .font(.system(size: 18))
     .padding(.top, 20)
     .padding([.leading, .trailing], 50)
     */
    VStack {
        Text("Notes")
            .padding(.top, 20)
            .padding([.leading, .trailing], 50)
            .font(.system(size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
        TextField("Anything you want to add", text: $notes)
        //.padding(.top, 10)
            .padding(.leading, 50)
            .font(.system(size: 18))
            .foregroundColor(Color(red: 0.03137, green: 0.1608, blue: 0.8118))
        Button("Upload Image") {
            showImagePicker = true
        }
        .padding(.top, 20)
        if let image = pickedImage {
            Image(uiImage: image)
                .resizable()
                .frame(width: 220, height: 220)
                .padding(.top, 20)
        }
        Button("Send") {
            //.task {
            // we verify the report's data before we process it
            if self.verifyData() {
                self.showProgress = true
                // we extract date and hour and minute here
                self.processDateTime(date: self.lostDate, time: self.lostTime)
                // check pet age
                var age = 0
                if Int(self.petAge) != nil {
                    age = Int(self.petAge)!
                    print("age is set to \(age)")
                }
                //self.processTime(time: self.lostTime)
                // send info to firebase
                // before we send it, we prepare the image by
                // saving it in temp and get a url
                // we do it here, we can make sure the user decided
                // to use the image before we do these extra job
                if self.pickedImage != nil {
                    //self.generatingImageUrl(
                    // self.generatingImageUrl(completion: { url in
                    // if there is an image, we pass the image
                    // and the image url
                    // we pass it as nil if we can't get the
                    // url
                    // so we wait to see if we can get the url
                    //DispatchQueue.global(qos: .default).async { //.async {
                    print("pickedImage != nil")
                    //print("petName \(self.petName)")
                    Task {
                        if let url = await self.generatingImageUrl() {
                            let resultsTuple = await self.firebaseClient.processDogReport(name: petName, type: self.petType, breed: petBreed, gender: petGender, age: age, lostPlace: lostLocation, lostDate: self.processedDate, hour: hour, minute: minute, notes: notes, lat: latitudeGot, lng: longitudeGot, isLost: self.selectedReport == "Found" ? false : true, isFound: false, image: pickedImage, imageUrl: url)
                            
                            if resultsTuple.result == true {
                                print("report success")
                                //self.clearForm()
                                print("we get the download url from the result of processDogReport's dog")
                                print(resultsTuple.dog!.dogImages.first!.value)
                                self.downloadUrlString = resultsTuple.dog!.dogImages.first!.value
                                self.dogFirebase = resultsTuple.dog
                                self.reportSent = 1
                            } else {
                                print("report failed")
                                self.reportSent = 0
                            }
                        }
                    }
                    
                } else {
                    print("picked image == nil")
                    //print("petName \(self.petName)")
                    Task {
                        let resultsTuple = await self.firebaseClient.processDogReport(name: petName, type: self.petType, breed: petBreed, gender: petGender, age: age, lostPlace: lostLocation, lostDate: self.processedDate, hour: hour, minute: minute, notes: notes, lat: latitudeGot, lng: longitudeGot, isLost: self.selectedReport == "Found" ? false : true, isFound: false, image: pickedImage, imageUrl: imageUrl)
                        if resultsTuple.result == true {
                            print("report success")
                            self.dogFirebase = resultsTuple.dog
                            self.reportSent = 1
                            
                        } else {
                            print("report failed")
                            self.reportSent = 0
                        }
                        
                    }
                }
                // end of verify
            } else {
                // we show alert that certain fields are required
                self.fieldsInvalidAlert()
            }
            //}
        } // end of button
        .padding(.top, 10)
    }
}
     .navigationDestination(isPresented: $shouldNavigateMap) {
         // latGot, lngGot are not using in lost location view
         // latGot, lngGot are for passing back the position user clicked on the map
         // which we didn't use.
         LostLocationView(userLocationStruct: userLocation, latitudeGot: $latitudeGot, longitudeGot: $longitudeGot, marker: $marker, shouldReportLocation: $shouldReportLocation, reportOrShow: true)
     }
     
     .onChange(of: shouldReportLocation, perform: { should in
         if should == 1 {
             self.requestAddressGeo()
         }
     })
     .sheet(isPresented: $showImagePicker, content: {
         ImagePicker(image: $pickedImage)
     })
     .onAppear() {
         
         switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
         case .notDetermined:
             // ask for access
             PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { result in
                 print("PHPhoto Library: result \(result)")
             })
         case .restricted, .denied:
             var a = 1
             // sorry
         case .authorized:
             // we have full access
             var b = 1
             // new option:
         case .limited:
             // we only got access to some photos of library
             var c = 1
         }
     }
     /*
     .onChange(of: self.selectedGender) { genderWord in
         if genderWord == "Male" {
             self.petGender = 1
             print("set gender to Male")
         } else if genderWord == "Female" {
             self.petGender = 2
             print("set gender to Female")
         }
         //print("set gender to 1 or 2")
     }
     .onChange(of: self.selectedType) { type in
         print("selected type: \(type)")
         if type == "Other" {//&& self.typeInputed != "" {
             self.petType = self.typeInputed
             print("other clause")
         } else if type != "Choose" {
             self.typeInputed = self.selectedType
             self.petType = self.selectedType
             print("other than choose clause")
         } else {
             self.petType = ""
             self.typeInputed = ""
         }
         print("type recorded: \(self.petType)")
     }
      */
     private func requestAddressGeo() {
         if marker != nil {
             GeoHandler.requestAddress(lat: marker!.position.latitude, lng: marker!.position.longitude) { response, error in
                 print(response)
                 self.lostLocationAddress = response?.results[0].formatted_address ?? ""
                 self.lostLocation = self.lostLocationAddress
             }
         }
     }
     /*
      func loadImage() {
      guard let inputImage = pickedImage else { return }
      loadedImage = Image(uiImage: inputImage)
      print("loaded image")
      }
      */
     private func generatingImageUrl() async -> URL? {
         //private func generatingImageUrl(completion: @escaping (URL?) -> Void) {
         if let image = pickedImage {
             Image(uiImage: image)
             let imgName = "\(UUID().uuidString).jpeg"
             let documentDirectory = NSTemporaryDirectory()
             let localPath = documentDirectory.appending(imgName)
             //if image != nil {
             let data = image.jpegData(compressionQuality: 1.0)! as NSData
             data.write(toFile: localPath, atomically: true)
             imageUrl = URL.init(fileURLWithPath: localPath)
             //}
             guard imageUrl != nil else {
                 //completion(nil)
                 print("url == nil")
                 return nil
             }
             print("url != nil")
             return imageUrl
             //completion(url)
         } else {
             return nil
         }
         
     }
     private func clearForm() {
         self.petName = ""
         self.petBreed = ""
         self.petGender = ""
         self.petAge = ""
         self.lostLocation = ""
         self.lostDate = Date()
         self.notes = ""
         self.pickedImage = nil
         self.imageUrl = nil
         self.reportSent = 0
         self.petType = ""
         self.selectedGender = "Choose"
         self.selectedType = "Choose"
         self.reportIntro = "Please choose to report lost or report found"
         
     }
     // verify the validity of the data before sending it to firebase
     // present alerts
     private func verifyData() -> Bool {
         //print("verifying, gender = \(self.petGender)")
         // this is to make sure if the user inputed a type,
         // we always use this type rather than the type picker
         // the user may change this field after the type picker
         if self.typeInputed != "" {
             self.petType = self.typeInputed
         }
         // pet name is needed if it is a lost dog report
         if self.petName == "" && self.selectedReport == "Lost" {
             showNameError = true
         } else {
             showNameError = false
         }
         if self.lostLocation == "" {
             showLocationError = true
         } else {
             showLocationError = false
         }
         if !self.dateChanged {
             showDateError = true
         } else {
             showDateError = false
         }
         return !showNameError && !showLocationError && !showDateError
     }
     */
