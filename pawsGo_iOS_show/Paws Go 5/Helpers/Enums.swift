//
//  Enums.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-06.
//

import Foundation

enum AuthState {
    case
        NORMAL,
        LOGGED_IN,
        LOGGED_OUT
}

enum AppState {
    case
        NORMAL,
        CREATE_ACCOUNT,
        SIGN_IN_ERROR,
        SIGN_UP_ERROR,
        SAVING_ERROR
    
}

enum TextInputFieldType {
    case
        EMAIL,
        PASSWORD,
        CONFIRM_PASSWORD
}

enum MessageType {
    case
        MESSAGES_SENT,
        MESSAGES_RECEIVED
}


