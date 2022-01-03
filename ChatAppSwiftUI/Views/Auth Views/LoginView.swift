//
//  LoginView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    var body: some View {
        VStack(spacing: 20){
            HStack{
                Image(systemName: "mail")
                    .font(.system(size: 32))
                    .frame(width: 50)
                
                TextField("Email", text: $loginViewModel.email)
                
            }
            .padding(.top, 50)
            HStack{
                Image(systemName: "lock")
                    .font(.system(size: 32))
                    .frame(width: 50)
                TextField("Password", text: $loginViewModel.password)
                
            }
            
            Button {
                print("login")
                loginViewModel.loginUser()
            } label:{
                Text("Login")
            }
            
            HStack{
                Text("No account?")
                
                Button {
                    
                    print("opening register view")
                    
                } label: {
                    NavigationLink("Register", destination: ResgisterView())
                }
                
            }
            Spacer()
            
        }
        .padding()
        .navigationBarTitle("Sign In")
        
    }
        
}


