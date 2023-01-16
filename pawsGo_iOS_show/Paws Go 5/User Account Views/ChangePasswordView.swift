//
//  ChangePasswordView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-24.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @State private var currentPassword : String = ""
    @State private var newPassword : String = ""
    @State private var confirmPassword : String = ""
    private var textValidator = TextValidator()
    @State private var currentPasswordError = ""
    @State private var newPasswordError = ""
    @State private var confirmPasswordError = ""
    @State private var showProgress = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if !isLandscape {
                    VStack {
                        
                        VStack {
                            Image(uiImage: UIImage(named: "password.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .padding(.top, 60)
                            
                            Text("Current Password")
                                .padding(.top, 60)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            SecureField("fkalgm64h", text: self.$currentPassword)
                                .onChange(of: self.currentPassword) { current in
                                    if current != "" {
                                        self.currentPasswordError = textValidator.checkPasswordInput(input: current, type: TextInputFieldType.PASSWORD)
                                    }
                                }
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            
                            Text(self.$currentPasswordError.wrappedValue)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .foregroundColor(Color.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                        }
                        VStack {
                            
                            Text("New Password")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .font(.system(size: CONTENT_FONT_SIZE))
                            
                            SecureField("qewfo6esa4", text: self.$newPassword)
                                .onChange(of: self.newPassword) { new in
                                    if new != "" {
                                        self.newPasswordError = textValidator.checkPasswordInput(input: new, type: TextInputFieldType.PASSWORD)
                                    }
                                }
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            
                            Text(self.$newPasswordError.wrappedValue)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .foregroundColor(Color.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            
                            Text("Confirm New Password")
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            SecureField("qewfo6esa4", text: self.$confirmPassword)
                                .onChange(of: self.confirmPassword) { confirm in
                                    if confirm != "" {
                                        self.confirmPasswordError = textValidator.checkConfirmPasswordInput(firstInput: self.newPassword, secondInput: confirm, type: TextInputFieldType.CONFIRM_PASSWORD)
                                    }
                                }
                                .padding(.top, 5)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            
                            Text(self.$confirmPasswordError.wrappedValue)
                                .padding([.leading, .trailing], 50)
                            //.padding(.top, 5)
                                .foregroundColor(Color.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            
                            Button("Send") {
                                self.showProgress = true
                                Task {
                                    if await firebaseClient.changePassword(currentPassword: self.currentPassword, newPassword: self.newPassword, email: firebaseClient.auth.currentUser!.email!) {
                                        self.changePasswordSuccessAlert()
                                    } else {
                                        self.changePasswordErrorAlert()
                                    }
                                    self.showProgress = false
                                }
                            }
                            .padding(.top, 20)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            Spacer()
                        }
                    }
                } else {
                    // landscape
                    HStack {
                        //VStack {
                        Spacer()
                        VStack {
                            Text("Change Password")
                                .padding(.top, 120)
                                .padding([.leading, .trailing], 20)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.system(size: TITLE_FONT_SIZE))
                            
                            HStack {
                                Image(uiImage: UIImage(named: "password.png")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80, alignment: .center)
                                    .padding(.top, 20)
                            }
                                
                            Spacer()
                        } // section 1
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 200)
                        VStack(alignment: .leading) {
                            VStack {
                                Text("Current Password")
                                    .padding(.top, 40)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                
                                SecureField("fkalgm64h", text: self.$currentPassword)
                                    .onChange(of: self.currentPassword) { current in
                                        if current != "" {
                                            self.currentPasswordError = textValidator.checkPasswordInput(input: current, type: TextInputFieldType.PASSWORD)
                                        }
                                    }
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                
                                Text(self.$currentPasswordError.wrappedValue)
                                    .padding([.leading, .trailing], 50)
                                    .padding(.top, 5)
                                
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.black)
                            }
                            VStack {
                                
                                Text("New Password")
                                    .padding(.top, 10)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                
                                SecureField("qewfo6esa4", text: self.$newPassword)
                                    .onChange(of: self.newPassword) { new in
                                        if new != "" {
                                            self.newPasswordError = textValidator.checkPasswordInput(input: new, type: TextInputFieldType.PASSWORD)
                                        }
                                    }
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                
                                Text(self.$newPasswordError.wrappedValue)
                                    .padding([.leading, .trailing], 50)
                                    .padding(.top, 5)
                                    .foregroundColor(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                                
                                Text("Confirm New Password")
                                    .padding(.top, 10)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                
                                SecureField("qewfo6esa4", text: self.$confirmPassword)
                                    .onChange(of: self.confirmPassword) { confirm in
                                        if confirm != "" {
                                            self.confirmPasswordError = textValidator.checkConfirmPasswordInput(firstInput: self.newPassword, secondInput: confirm, type: TextInputFieldType.CONFIRM_PASSWORD)
                                        }
                                    }
                                    .padding(.top, 5)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                
                                Text(self.$confirmPasswordError.wrappedValue)
                                    .padding([.leading, .trailing], 50)
                                    .foregroundColor(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                                HStack {
                                    Button("Send") {
                                        self.showProgress = true
                                        Task {
                                            if await firebaseClient.changePassword(currentPassword: self.currentPassword, newPassword: self.newPassword, email: firebaseClient.auth.currentUser!.email!) {
                                                self.changePasswordSuccessAlert()
                                            } else {
                                                self.changePasswordErrorAlert()
                                            }
                                            self.showProgress = false
                                        }
                                    }
                                    .padding(.top, 10)
                                    .padding(.bottom, 50)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                }
                            } // sub VStack
                            
                        } // VStack // section 2
                        Spacer()
                    } // HStack
                }// end of if clause
            } // end of ScrollView
            CustomProgressView(showProgress: self.$showProgress)
        } // end of ZStack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .navigationBarTitle("Change Password")
        
    }
    
    private func changePasswordSuccessAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let successAlert = UIAlertController(
            title: "Change Password",
            message: "The password was changed successfully.", preferredStyle: .alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(successAlert, animated: true)
    }
    
    private func changePasswordErrorAlert() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Change Password",
            message: "There is error.  The server may be down.  Please make sure you have WIFI and try again later.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        
        
        ChangePasswordView()
    }
}
