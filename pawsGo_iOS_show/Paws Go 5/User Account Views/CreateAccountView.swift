//
//  CreateAccountView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject private var firebaseClient : FirebaseClient
    @EnvironmentObject private var databaseManager : DatabaseManager
    @State var shouldNavigateMain = false
    @Environment(\.managedObjectContext) var moc

    var textValidator = TextValidator()
    @State var email = ""
    @State var name = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var emailError = ""
    @State var passwordError = ""
    @State var confirmPasswordError = ""
    @State var showProgress = false
    
    var body: some View {

        ZStack {
            ScrollView {
                if !isLandscape {
                    VStack {
                        VStack {
                            Image(uiImage: UIImage(named: "collar.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .padding(.top, 40)
                            
                            Text("Create Account")
                                .bold()
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 30)
                                .font(.system(size: TITLE_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        .padding(.top, 120)
                        
                        VStack {
                            Text("Name")
                                .padding(.top, 40)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField(
                                "Ben",
                                text: $name)
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 5)
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            
                            Text("Email")
                                .padding(.top, 9)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .font(.system(size: CONTENT_FONT_SIZE))
                            TextField(
                                "ben@abc.com",
                                text: $email)
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .onChange(of: email, perform: { email in
                                print("email changed: \(email)")
                                if email != "" {
                                    emailError = textValidator.checkEmailInput(input: email, type: TextInputFieldType.EMAIL)
                                    print("email error: \(emailError)")
                                }
                            })
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text($emailError.wrappedValue)
                                .foregroundColor(Color.red)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading, .trailing], 60)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            
                        }
                        VStack {
                            Text("Password")
                                .padding(.top, 5)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .font(.system(size: CONTENT_FONT_SIZE))
                            SecureField(
                                "kgjqu43l",
                                text: $password)
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .onChange(of: password, perform: { pass in
                                print("password changed: \(pass)")
                                if password != "" {
                                    passwordError = textValidator.checkPasswordInput(input: pass, type: TextInputFieldType.PASSWORD)
                                }
                                print("password error: \(passwordError)")
                            })
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text($passwordError.wrappedValue)
                                .foregroundColor(Color.red)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading, .trailing], 60)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            //.padding(.top, 30)
                            Text("Confirm Password")
                                .padding(.top, 5)
                                .padding([.leading, .trailing], 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .font(.system(size: CONTENT_FONT_SIZE))
                            SecureField(
                                "kgjqu43l",
                                text: $confirmPassword)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                //.padding(.bottom, 40)
                                .onChange(of: confirmPassword, perform: { pass in
                                    print("confirm password changed: \(pass)")
                                    if confirmPassword != "" {
                                        confirmPasswordError = textValidator.checkConfirmPasswordInput(firstInput: password, secondInput: pass, type: TextInputFieldType.CONFIRM_PASSWORD)
                                    }
                                    print("password error: \(confirmPasswordError)")
                                })
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text($confirmPasswordError.wrappedValue)
                                .foregroundColor(Color.red)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading, .trailing], 60)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                        }
                        
                        Button("Send") {
                            // sign up
                            if name != "" && email != "" && password != "" &&
                                emailError == "" &&
                                passwordError == "" && confirmPasswordError == "" {
                                firebaseClient.processSignUp(name: name, email: email.lowercased(), password: password)
                                //clearFields()
                                showProgress = true
                            } else {
                                print("Empty fields")
                            }
                        }
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .padding(.top, 30)
                        Spacer()
                    } // end of VStack
                } else {
                    // landscape
                    HStack {
                        VStack(alignment: .center) {
                            //Spacer()
                            Text("Create Account")
                                .bold()
                                .padding(.leading, 40)
                                .padding(.trailing, 40)
                                //.padding(.leading, 40)
                                .padding(.top, 120)
                                .font(.system(size: 22))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            HStack {
                                Spacer()
                                Image(uiImage: UIImage(named: "collar.png")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(.top, 20)
                                //.padding(.all, 20)
                                Spacer()
                            }
                                
                            Spacer()
                            
                        } // section 1
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 200)
                        .padding(.leading, 40)
                        //.font(.system(size: CONTENT_FONT_SIZE))
                        VStack {
                            VStack {
                                //VStack {
                                Text("Name")
                                    .padding(.top, 40)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                TextField(
                                    "Ben",
                                    text: $name)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                
                                Text("Email")
                                    .padding(.top, 9)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                TextField(
                                    "ben@abc.com",
                                    text: $email)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .onChange(of: email, perform: { email in
                                    print("email changed: \(email)")
                                    if email != "" {
                                        emailError = textValidator.checkEmailInput(input: email, type: TextInputFieldType.EMAIL)
                                        print("email error: \(emailError)")
                                    }
                                })
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                Text($emailError.wrappedValue)
                                    //.foregroundColor(Color.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 60)
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                
                            }
                            VStack {
                                Text("Password")
                                    .padding(.top, 5)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                TextField(
                                    "kgjqu43l",
                                    text: $password)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .onChange(of: password, perform: { pass in
                                    print("password changed: \(pass)")
                                    if password != "" {
                                        passwordError = textValidator.checkPasswordInput(input: pass, type: TextInputFieldType.PASSWORD)
                                    }
                                    print("password error: \(passwordError)")
                                })
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                Text($passwordError.wrappedValue)
                                    .foregroundColor(Color.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 60)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                                //.padding(.top, 30)
                                Text("Confirm Password")
                                    .padding(.top, 5)
                                    .padding([.leading, .trailing], 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                TextField(
                                    "kgjqu43l",
                                    text: $confirmPassword)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                //.padding(.bottom, 40)
                                .onChange(of: confirmPassword, perform: { pass in
                                    print("confirm password changed: \(pass)")
                                    if confirmPassword != "" {
                                        confirmPasswordError = textValidator.checkConfirmPasswordInput(firstInput: password, secondInput: pass, type: TextInputFieldType.CONFIRM_PASSWORD)
                                    }
                                    print("password error: \(confirmPasswordError)")
                                })
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                                Text($confirmPasswordError.wrappedValue)
                                    .foregroundColor(Color.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: CONTENT_FONT_SIZE))
                                    .padding([.leading, .trailing], 60)
                                    .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            } // end of enclosing VStack
                            HStack {
                                Button("Send") {
                                    // sign up
                                    if name != "" && email != "" && password != "" &&
                                        emailError == "" &&
                                        passwordError == "" && confirmPasswordError == "" {
                                        firebaseClient.processSignUp(name: name, email: email.lowercased(), password: password)
                                        //clearFields()
                                        showProgress = true
                                    } else {
                                        print("Empty fields")
                                    }
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                            } // end of HStack
                        } // section 2
                        
                    } // end of HStack
                }// end of if clause
            } // end of Scrollview
            CustomProgressView(showProgress: self.$showProgress)
            
        } // end of ZStack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)        .ignoresSafeArea()
        .navigationDestination(isPresented: $shouldNavigateMain) {
            MainView(id: firebaseClient.auth.currentUser?.uid ?? "XX")
                .environmentObject(firebaseClient)
                .environmentObject(databaseManager)
        }
        .onReceive(firebaseClient.$authState, perform: { state in
            if (state == AuthState.LOGGED_IN) {
                
                // when auth state changed to logged in
                // we know that the user successfully registered
                // we then create the local user object for the user
                self.createUserCore(id: firebaseClient.auth.currentUser!.uid, name: self.name, email: self.email.lowercased())
                self.saveContext()
                self.clearFields()
                shouldNavigateMain = true
            }
        })
        .onReceive(firebaseClient.$appState, perform: { state in
            switch state {
                case AppState.SIGN_UP_ERROR:
                    self.signUpErrorAlert()
                    showProgress = false
                default:
                    showProgress = false
            }
            
        })
        
    } // end of body
    
    private func clearFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
        
    }
    
    private func createUserCore(id: String, name: String, email: String) {
        let userCore = UserCore(context: moc)
        userCore.userID = id
        userCore.userName = name
        userCore.userEmail = email
        userCore.dogs = [:]
        userCore.lostDogs = [:]
        userCore.messagesReceived = [:]
        userCore.messagesSent = [:]
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("saving changes error \(error.localizedDescription)")
        }
    }
    
    private func signUpErrorAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Create Account Error",
            message: "There is error in the server.  Please try again later.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}

