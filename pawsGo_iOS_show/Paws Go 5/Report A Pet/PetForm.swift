//
//  PetForm.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2023-01-03.
//

import SwiftUI
import GoogleMaps
import Photos

struct PetForm: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @State var userLocation : LocationStruct = LocationStruct(name: "Here", coordinate: CLLocationCoordinate2D(latitude: 43.8828, longitude: 79.4403))
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var pet : DogCore?
    @Binding var petName : String
    @Binding var petType : String
    @Binding var petBreed : String
    @Binding var petGender : Int
    @Binding var petAge : String
    @Binding var lostDate : Date
    @Binding var lostPlace : String
    @Binding var lostTime : Date
    @Binding var lostDateString : String
    @Binding var lostTimeString : String 
    @Binding var hour : Int?
    @Binding var minute : Int?
    @Binding var notes : String
    let genderChoice = ["Choose", "Male", "Female"]
    @State private var selectedGender = "Choose"
    let petTypeChoice = ["Choose", "Dog", "Cat", "Bird", "Other"]
    @State private var selectedType = "Choose"
    @Binding var latGot : Double?
    @Binding var lngGot : Double?
    @State var marker : GMSMarker?
    @State private var shouldReportLocation = 0
    @State private var lostLocationAddress = ""
    @State private var showDateError = false
    @State private var showLocationError = false
    @State private var showNameError = false
    @State private var dateChanged = false
    @State private var selectedReport = "Lost"
    @State private var showImagePicker = false
    @Binding var pickedImage : UIImage?
    @State var reportOrShow = false
    @State var dateRange : ClosedRange<Date>?
    @Binding var shouldSendReport : Int
    
    var body: some View {

        let dateRange: ClosedRange<Date> = {
                    let calendar = Calendar.current
                    let startComponents = DateComponents(year: 2012, month: 12, day: 10)
                    let currentDate = Date()
                    let year = currentDate
                    let currentComponents = Calendar.current.dateComponents([.day, .month, .year], from: currentDate)
                    let endComponents = DateComponents(year: 2022, month: 12, day: 10)
                    return calendar.date(from: startComponents)!
                    ...
                    calendar.date(from: currentComponents)!
                }()
        
        ZStack {
            
            ScrollView {
                //if !isLandscape {
                    VStack {
                        VStack {
                            if self.pet != nil && !self.isLandscape {
                                AsyncImage(url: URL(string: (pet?.dogImages?.first?.value) ?? ""),
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
                            }
                            Text("Pet Name")
                                .padding(.top, 60)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(self.showNameError != true ? (colorScheme == .dark ? Color.white : Color.black) : Color.red)
                            TextField("Roger", text: self.$petName)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .padding([.leading, .trailing], 50)
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            
                            HStack {
                                Text("Pet Type")
                                    .padding(.top, 10)
                                    .padding(.leading, 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Picker("", selection: self.$selectedType) {
                                    ForEach(self.petTypeChoice, id:\.self) {
                                        Text($0)
                                    }
                                }
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            }
                            
                            TextField("Dog", text: self.$petType)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text("Pet Breed")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField("Shiba Inu", text: self.$petBreed)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                        }
                        VStack {
                            HStack {
                                Text("Pet Gender")
                                    .padding(.top, 10)
                                    .padding(.leading, 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Picker("", selection: self.$selectedGender) {
                                    ForEach(self.genderChoice, id:\.self) {
                                        Text($0)
                                    }
                                }
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                //.padding(.trailing, 100)
                                
                            }
                            Text("Pet Age")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField("3", text: self.$petAge)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            HStack {
                                Text("Lost Date")
                                    .padding(.top, 10)
                                    .padding(.leading, 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    //.foregroundColor(self.showDateError == true ? Color.red : Color.black)
                                    .foregroundColor(self.showDateError != true ? (colorScheme == .dark ? Color.white : Color.black) : Color.red)
                                DatePicker(
                                    "",
                                    selection: $lostDate,
                                    in: dateRange,
                                    displayedComponents: [.date]
                                )
                                .padding(.top, 10)
                                .padding(.trailing, 50)
                                .onChange(of: self.lostDate, perform: { value in
                                    print(value)
                                    print("date is set")
                                    self.dateChanged = true
                                })
                                .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            }
                            Text(self.$lostDateString.wrappedValue)
                                .padding(.top, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                .padding([.leading, .trailing], 50)
                            // we can't use the textfield hint to show the inputed info
                            // we need to put the info in text binding
                            HStack {
                                Text("Lost Time")
                                    .padding(.top, 10)
                                    .padding(.leading, 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                
                                DatePicker("", selection: self.$lostTime, displayedComponents: [.hourAndMinute])
                                    .padding(.top, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing, 50)
                                    .onChange(of: self.lostTime, perform: { value in
                                        print(value)
                                        print("time is set")
                                        //self.timeChanged = true
                                    })
                                    .accentColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            }
                            Text(self.$lostTimeString.wrappedValue)
                                .padding(.top, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                .padding([.leading, .trailing], 50)
                            
                            Text("Lost Location")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(self.showLocationError != true ? (colorScheme == .dark ? Color.white : Color.black) : Color.red)
                            TextField("Steeles and Midland, Ontario", text: self.$lostPlace)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            NavigationLink("Show Location") {
                                LostLocationView(userLocationStruct: self.userLocation, latitudeGot: self.$latGot, longitudeGot: self.$lngGot, marker: self.$marker, shouldReportLocation: self.$shouldReportLocation, reportOrShow: self.reportOrShow)
                            }
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .padding(.top, 10)
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        }
                        VStack {
                            Text("Notes")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField("Anything you want to add.", text: self.$notes)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            if let image = pickedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 220, height: 220)
                                    .padding(.top, 10)
                            }
                            Button("Upload Picture") {
                                self.showImagePicker = true
                            }
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .padding(.top, 10)
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            Button("Send") {
                                // verify data
                                if self.verifyData() {
                                    self.shouldSendReport = 1
                                } else {
                                    self.fieldsInvalidAlert()
                                }
                            }
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .padding(.top, 10)
                            .padding(.bottom, self.reportOrShow ? 40 : 20)
                            .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        }
                    } // end of enclosing VStack
                    // landscape
                //} // end of if clause
            } // end of Scroll view
            .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
            .onAppear() {
                if self.pet != nil {
                    self.preprocessPetInfo()
                }
            }
            .onChange(of: self.selectedGender) { gender in
                if gender == "Male" {
                    self.petGender = 1
                } else {
                    self.petGender = 2
                }
            }
            .onChange(of: self.shouldReportLocation) { should in
                if (should == 1) {
                    self.requestAddressGeo()
                }
            }
            .onChange(of: self.selectedType) { type in
                if type != "Choose" && type != "Other" {
                    self.petType = type
                } else {
                    self.petType = ""
                }
            }
            .onChange(of: self.lostDate) { date in
                if date != nil {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    self.lostDateString = dateFormatter.string(from: date)
                }
            }
            .onChange(of: self.lostTime) { time in
                if time != nil {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm a"
                    self.lostTimeString = dateFormatter.string(from: time)
                }
            }
            .sheet(isPresented: self.$showImagePicker, content: {
                ImagePicker(image: self.$pickedImage)
            })
            .onAppear() {
                
                switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
                case .notDetermined:
                    // ask for access
                    PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { result in
                        print("PHPhoto Library: result \(result)")
                    })
                    
                default:
                    PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { result in
                        print("PHPhoto Library: result \(result)")
                    })
                }
            }
        } // end of ZStack
    }
    
    private func preprocessPetInfo() {
            
        self.petName = self.extractInfo(info: self.pet!.dogName)
        self.petType = self.extractInfo(info: self.pet!.animalType)
        self.petBreed = self.extractInfo(info: self.pet!.dogBreed)

        if String(self.pet!.dogAge) == "0" {
            self.petAge = "Unknown"
        } else {
            self.petAge = self.extractInfo(info: String(self.pet!.dogAge))
        }
        
        // show gender if there is any, in the picker
        if self.pet!.dogGender == 1 {
            self.selectedGender = "Male"
        } else if self.pet!.dogGender == 2 {
            self.selectedGender = "Female"
        } else {
            self.selectedGender = "Choose"
        }
        
        // show type if there is any, in the picker
        if self.pet!.animalType != nil && self.pet!.animalType != "" && (self.pet!.animalType == "Dog" || pet!.animalType == "Cat" || pet!.animalType == "Bird") {
            self.selectedType = self.pet!.animalType!
        }
        
        self.lostPlace = self.extractInfo(info: self.pet!.placeLastSeen)
        
        self.notes = self.extractInfo(info: self.pet!.notes)
        if self.pet!.dateLastSeen != nil && self.pet!.dateLastSeen != "" {
            self.lostDate = self.convertDatabaseDateToDatePickerDate(dateString: self.pet!.dateLastSeen!)
            self.lostDateString = self.pet!.dateLastSeen!
        } else {
            self.lostDateString = "Not Set"
        }
        if self.pet!.hour != nil {
            self.lostTime = self.convertDatabaseTimeToDatePickerTime(hour: self.pet!.hour, minute: self.pet!.minute)
            self.lostTimeString = String(self.pet!.hour) + ":" + String(self.pet!.minute)
        } else {
            self.lostTimeString = "Not Set"
        }
    }
    
    private func prepareDateRange() {
        self.dateRange = {
            let calendar = Calendar.current
            let startComponents = DateComponents(year: 2012, month: 12, day: 10)
            let currentDate = Date()
            let year = currentDate
            let currentComponents = Calendar.current.dateComponents([.day, .month, .year], from: currentDate)
            let endComponents = DateComponents(year: 2022, month: 12, day: 10)
            return calendar.date(from: startComponents)!
            ...
            calendar.date(from: currentComponents)!
        }()
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
    
    private func convertDatabaseDateToDatePickerDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let databaseDate = dateFormatter.date(from: dateString)
         
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let resultString = dateFormatter.string(from: databaseDate!)
        
        return dateFormatter.date(from: resultString)!
    }
    
    private func convertDatabaseTimeToDatePickerTime(hour: Int16, minute: Int16) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm a"
        
        let timeComponents = DateComponents(hour: Int(hour), minute: Int(minute))
        
        return Calendar.current.date(from: timeComponents)!
    }
    
    // verify the validity of the data before sending it to firebase
    // present alerts
    private func verifyData() -> Bool {
        //print("verifying, gender = \(self.petGender)")
        // this is to make sure if the user inputed a type,
        // we always use this type rather than the type picker
        // the user may change this field after the type picker
        //if self.selectedType != "" {
            //self.petType = self.typeInputed
        //}
        // pet name is needed if it is a lost dog report
        if self.petName == "" && self.selectedReport == "Lost" {
            self.showNameError = true
        } else {
            self.showNameError = false
        }
        if self.lostPlace == "" {
            self.showLocationError = true
        } else {
            self.showLocationError = false
        }
        if self.lostDateString == "" {
            self.showDateError = true
        } else {
            self.showDateError = false
        }
        return !showNameError && !showLocationError && !showDateError
    }
    
    private func clearForm() {
        self.petName = ""
        self.petBreed = ""
        self.petGender = 0
        self.petAge = ""
        self.lostPlace = ""
        self.lostDate = Date()
        self.lostTime = Date()
        self.notes = ""
        self.pickedImage = nil
        //self.reportSent = 0
        self.petType = ""
        self.selectedGender = "Choose"
        self.selectedType = "Choose"
        //self.reportIntro = "Please choose to report lost or report found"
        
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
}
/*
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
 
 */

