//
//  LoginView.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import SwiftUI


struct LoginView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape : Bool { verticalSizeClass == .compact }
    
    @EnvironmentObject var firebaseClient : FirebaseClient
    @EnvironmentObject var databaseManager : DatabaseManager
    @Environment(\.managedObjectContext) var moc
    @State private var shouldNavigateCreateAccount = false
    @State private var shouldNavigateMain = false
    @State private var email = ""
    @State private var password = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    private var textValidator = TextValidator()
    @State private var showProgress = false
    @State private var viewStack = NavigationPath()
    @State private var passwordResetResult : Bool?
    
    
    var body: some View {
        
        VStack {
            ZStack {
                
            ScrollView {
                // portrait
                if !isLandscape {
                    VStack {
                        Image(uiImage: UIImage(named: "happy.png")!)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.all, 40)
                            .padding(.top, 50)
                        
                        Text("Login")
                            .padding([.leading, .trailing], 50)
                            .font(.system(size: TITLE_FONT_SIZE))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text("Email")
                            .padding(.top, 50)
                            .padding([.leading, .trailing], 50)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        TextField("ben@abc.com", text: $email)
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .onChange(of: email, perform: { emailText in
                                if emailText != "" {
                                    emailError = textValidator.checkEmailInput(input: emailText, type: TextInputFieldType.EMAIL)
                                }
                            })
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                        Text($emailError.wrappedValue)
                            .foregroundColor(Color.red)
                            .padding([.leading, .trailing], 60)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                        
                        Text("Password")
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        SecureField("adfeo4lmh", text: $password)
                            .padding([.leading, .trailing], 50)
                            .padding(.top, 5)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .onChange(of: password, perform: { pass in
                                if pass != "" {
                                    passwordError = textValidator.checkPasswordInput(input: pass, type: TextInputFieldType.PASSWORD)
                                }
                            })
                            .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                        Text($passwordError.wrappedValue)
                            .foregroundColor(Color.red)
                            .padding([.leading, .trailing], 60)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: CONTENT_FONT_SIZE))
                            .foregroundColor(colorScheme == .dark ? Color.pink: Color.red)
                        
                        Button("Send") {
                            print("email: \(email), pass: \(password)")
                            if (email != "" && password != "" && emailError == ""
                                && passwordError == "") {
                                print("inputs are valid")
                                firebaseClient.processSignIn(email: email, password: password)
                                showProgress = true
                                clearFields()
                            } else {
                                print("input fields are not correct")
                            }
                        }
                        .padding(.top, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                    }
                    
                    VStack {
                        Button("Create Account") {
                            shouldNavigateCreateAccount = true
                        }
                        .padding(.top, 10)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Button("Reset Password") {
                            self.resetPasswordAlert()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                        .font(.system(size: CONTENT_FONT_SIZE))
                        .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                        Spacer()
                    }
                } else {
                    // landscape
                    
                    HStack {
                        VStack {
                            //Spacer()
                            Text("Login")
                                .padding(.top, 60)
                                .padding([.leading, .trailing], 40)
                                .font(.system(size: TITLE_FONT_SIZE))
                                .bold()
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(uiImage: UIImage(named: "happy.png")!)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.all, 20)
                                //.padding(.top, 20)
                            Spacer()
                        } // section 1
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 200)
                        VStack {
                            Text("Email")
                                .padding(.top, 50)
                                .padding([.leading, .trailing], 50)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField("ben@abc.com", text: $email)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .onChange(of: email, perform: { emailText in
                                    if emailText != "" {
                                        emailError = textValidator.checkEmailInput(input: emailText, type: TextInputFieldType.EMAIL)
                                    }
                                })
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text($emailError.wrappedValue)
                                .foregroundColor(Color.red)
                                .padding([.leading, .trailing], 60)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            
                            Text("Password")
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            TextField("adfeo4lmh", text: $password)
                                .padding([.leading, .trailing], 50)
                                .padding(.top, 5)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .onChange(of: password, perform: { pass in
                                    if pass != "" {
                                        passwordError = textValidator.checkPasswordInput(input: pass, type: TextInputFieldType.PASSWORD)
                                    }
                                })
                                .foregroundColor(colorScheme == .dark ? COLOR_LIGHT_BLUE : COLOR_DARK_BLUE)
                            Text($passwordError.wrappedValue)
                                .foregroundColor(Color.red)
                                .padding([.leading, .trailing], 60)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.pink : Color.red)
                            
                            HStack {
                                Spacer()
                                Button("Send") {
                                    print("email: \(email), pass: \(password)")
                                    if (email != "" && password != "" && emailError == ""
                                        && passwordError == "") {
                                        print("inputs are valid")
                                        firebaseClient.processSignIn(email: email, password: password)
                                        showProgress = true
                                        clearFields()
                                    } else {
                                        print("input fields are not correct")
                                    }
                                }
                                .padding(.top, 10)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                //VStack {
                                Button("Create Account") {
                                    shouldNavigateCreateAccount = true
                                }
                                .padding(.top, 10)
                                .padding(.leading, 30)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                Button("Reset Password") {
                                    self.resetPasswordAlert()
                                }
                                .padding(.top, 10)
                                //.padding(.bottom, 50)
                                .padding(.leading, 30)
                                .font(.system(size: CONTENT_FONT_SIZE))
                                .foregroundColor(colorScheme == .dark ? Color.yellow : Color.blue)
                                Spacer()
                            }
                        } // end of VStack  section 2
                    } // end of HStack
                }// end of if clause
                
            } // end of enclosing Scrollview
                CustomProgressView(showProgress: self.$showProgress)
            } // end of ZStack
            Spacer()
        }
        //} // end of Navigatin Stack
        .background(colorScheme == .dark ? Color.black : COLOR_LIGHT_MODE_BACKGROUND)
        .navigationTitle("Paws Go")
        .navigationDestination(isPresented: $shouldNavigateMain) {
            MainView(id: firebaseClient.auth.currentUser?.uid ?? "YY")
                .environmentObject(firebaseClient)
                .environmentObject(databaseManager)
        }
        .navigationDestination(isPresented: $shouldNavigateCreateAccount) {
            CreateAccountView()
                .environmentObject(firebaseClient)
                .environmentObject(databaseManager)
                .navigationBarTitle("Paws Go", displayMode: .inline)
                .toolbar {
                    ToolbarItem {
                        
                    }
                }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(firebaseClient.$authState, perform: { state in
            if state == AuthState.LOGGED_IN {
                print("login view passed id \(firebaseClient.auth.currentUser!.uid)")
                //self.databaseManager.currentUserCore = self.databaseManager.fetchUser(id: firebaseClient.auth.currentUser!.uid)
                shouldNavigateMain = true
                print("state logged in detected")
            } else if state == AuthState.LOGGED_OUT {
                print("state logged out detected")
            }
                        
        })
        .onReceive(firebaseClient.$appState, perform: { state in
            switch state {
                case AppState.SIGN_IN_ERROR:
                    signInErrorAlert()
                    showProgress = false
                default:
                    showProgress = false
            }
        })
        .onAppear() {
            showProgress = false
        }
        .onChange(of: self.passwordResetResult) { result in
            if result != nil && result == true {
                self.resetEmailSentAlert()
                self.showProgress = false
            } else if result != nil && result == false {
                self.resetEmailFailureAlert()
                self.showProgress = false
            }
        }
         
    } // end of body
    
    private func clearFields() {
        email = ""
        password = ""
        emailError = ""
        passwordError = ""
    }
    
    private func signInErrorAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Login Error",
            message: "Either the password is not correct, or the email doesn't exist.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
    
    private func resetPasswordAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let alertController = UIAlertController(
            title: "Password Reset Email",
            message: "Please enter the email you used to register this app.  We'll send an email to you.  Please click the link in the email to reset the password.", preferredStyle: .alert)
        
        alertController.addTextField()
        
        let submitAction = alertController.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            let email = alertController.textFields![0].text ?? ""
            //var result : Bool?
            if email != "" {
                if textValidator.validate(value: email, type: TextInputFieldType.EMAIL) {
                    self.showProgress = true
                    Task {
                        passwordResetResult = await self.firebaseClient.processPasswordResetRequest(email: email)
                    }
                } else {
                    self.invalidEmailAlert()
                }
                
            }
        })
        
        window.rootViewController?.present(alertController, animated: true)
    }
    
    private func resetEmailSentAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Password Reset Email",
            message: "The password reset email was sent successfully.  Please check your email.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
    
    private func resetEmailFailureAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Password Reset Email",
            message: "The app couldn't send the password email to you.  The email doesn't exist in the database.  Please try another email.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
    
    private func invalidEmailAlert() {
            
        guard let window = UIApplication.shared.keyWindow else {
            return }
        
        let errorAlert = UIAlertController(
            title: "Invalid Email",
            message: "The email you entered is invalid.  Please try again.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            //print("confirmed")
        })
        
        window.rootViewController?.present(errorAlert, animated: true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
