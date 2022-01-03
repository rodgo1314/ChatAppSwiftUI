//
//  LoginViewModel.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject{
    @AppStorage("loggedIn") var loggedIn = false
    

    @Published var inputImage: UIImage?
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUp = false
    @Published var email_SignUp = ""
    @Published var password_SignUp = ""
    @Published var reEnterPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isLoading = false
    
    
    func signOut(){
        isLoading = true
        
        do{
            try Auth.auth().signOut()
            
            isLoading = false
            withAnimation{
                UserDefaults.standard.removeObject(forKey: "uid")
                
                self.loggedIn = false
                
            }
        
        }catch{
            
        }
    }
    func loginUser(){
        guard email != "", password != "", password.count >= 6 else {
            // show alert
            print("error")
            return
        }
        print("about to sign in")
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            
            
            guard let authResult = authResult else {
                print(authResult)
                return
            }
            
            print(authResult.user.uid)
            UserDefaults.standard.set(authResult.user.uid, forKey: "uid")
            
            
            withAnimation{self.loggedIn = true}
            self.email = ""
            self.password = ""
            
            
        }
    }
    
    func registerUser(){
        isLoading = true
        guard email_SignUp != "", password_SignUp != "", password_SignUp.count >= 6,
        reEnterPassword == password_SignUp,
        let inputImage = inputImage, firstName != "", lastName != "" else {
            // show alert
            print("error")
            return
        }
        
        Auth.auth().createUser(withEmail: email_SignUp, password: password_SignUp) { authResult, error in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard let authResult = authResult else{
                print("Error with auth result ")
                return
            }
            let userID = authResult.user.uid
            UserDefaults.standard.set(authResult.user.uid, forKey: "uid")

            let profilePictureFileName = "\(userID)/profile_picture.png"
            
            guard let imageData = inputImage.jpegData(compressionQuality: 0.25) else {
                print("no image data")
                return
            }
            
            StorageManager.shared.uploadProfilePicture(with: imageData, fileName: profilePictureFileName) { result in
                
                self.isLoading = false
                
                switch result{
                case .success(let url):
                    let user = User(id: userID, displayName: "\(self.firstName) \(self.lastName)", email: self.email_SignUp, groups: [], photoURL: url, isCurrentUser: false, userID: userID)
                    
                    

                    DatabaseManager.shared.createUser(id: userID, user: user)
                    self.firstName = ""
                    self.lastName = ""
                    self.inputImage = nil
                    self.email_SignUp = ""
                    self.password_SignUp = ""
                    self.reEnterPassword = ""
                    withAnimation{self.loggedIn = true}
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            
            
        }
        
        
        
        
    }
    
    
    
}
