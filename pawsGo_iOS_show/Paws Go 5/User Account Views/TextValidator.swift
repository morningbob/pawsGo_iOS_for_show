//
//  TextValidator.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation

class TextValidator {
    
    func checkEmailInput(input: String, type: TextInputFieldType) -> String {
        var errorMessage = ""
        if !validate(value: input, type: type) {
            return "It is not a valid email."
        } else {
            return ""
        }
    }
    
    func checkPasswordInput(input: String, type: TextInputFieldType) -> String {
        var errorMessage = ""
        
        if input.count < 8 {
            return "Password must have at least 8 characters"
        } else if !validate(value: input, type: type) {
            return "It is not a valid password.  Password can only contain letters and . _ % + -"
        } else {
            return ""
        }
    }
    
    func checkConfirmPasswordInput(firstInput: String, secondInput: String, type: TextInputFieldType) -> String {
        var errorMessage = ""
        
        if secondInput.count < 8 {
            return "Confirm password must have at least 8 characters"
        } else if firstInput != secondInput {
            return "Confirm password must be the same with password"
        } else if !validate(value: secondInput, type: type) {
            return "Confirm password is invalid.  Password can only contain letters and . _ % + -"
        } else {
            return ""
        }
    }
    
    func validate(value: String, type: TextInputFieldType) -> Bool {
        
        var regEx = ""
        
        switch (type) {
            case TextInputFieldType.EMAIL:
                regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            case TextInputFieldType.PASSWORD:
                regEx = "[A-Z0-9a-z._%+-]{8,25}"
            case TextInputFieldType.CONFIRM_PASSWORD:
                regEx = "[A-Z0-9a-z._%+-]{8,25}"
            default:
                regEx = ""
        }
        
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: value)
        //return false
    }
}
