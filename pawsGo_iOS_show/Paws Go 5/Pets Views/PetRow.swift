//
//  PetRow.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-18.
//

import SwiftUI

struct PetRow: View {
    
    var pet : DogCore
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack {
            AsyncImage(url: URL(string: (pet.dogImages?.first?.value) ?? ""),
                       content: { image in
                    image
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(10)
                        .scaledToFit()
                }, placeholder: { Image(uiImage: UIImage(named: "placeholder.png")!)
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(10)
                        .scaledToFit()
                }
                
            )
         
            VStack {
                if pet.dogName != nil {
                    Text(pet.dogName!)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        //.padding(.top, 30)
                }
                if pet.dogGender == 1  {
                    //if pet.dogGender == true {
                        Text("Gender:  Male")
                        .font(.system(size: CONTENT_FONT_SIZE))
                            .padding(.top, 5)
                } else if pet.dogGender == 2 {
                        Text("Gender:  Female")
                        .font(.system(size: CONTENT_FONT_SIZE))
                            .padding(.top, 5)
                }
        
            }
            Spacer()
            VStack {
                Text(pet.placeLastSeen ?? "")
                    //.padding(.top, 30)
                    .padding(.trailing, 10)
                    .font(.system(size: CONTENT_FONT_SIZE))
                Text(pet.dateLastSeen ?? "")
                    //.padding(.top, 5)
                    .padding(.trailing, 10)
                    .font(.system(size: CONTENT_FONT_SIZE))
            }
            //Spacer()
        }
       
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND).ignoresSafeArea()
        .cornerRadius(20)
    }
}

struct PetRow_Previews: PreviewProvider {
    //@Environment(\.managedObjectContext) var moc
    static var pet1 : DogCore = DogCore()
    //static var pet1 : DogCore = DogCore(dogName: "ben", placeLastSeen: "YY", dateLastSeen: "xx", ownerID: "aa", ownerName: "bb", ownerEmail: "cc")
    /*
    pet1.dogName = "ben"
    pet1.dateLastSeen = "xx"
    pet1.placeLastSeen = "xx"
    pet1.ownerID = "dd"
    pet1.ownerName = "ee"
    pet1.ownerEmail = "ff"
     */
    
    
    static var previews: some View {
        PetRow(pet: pet1)
    }
}
