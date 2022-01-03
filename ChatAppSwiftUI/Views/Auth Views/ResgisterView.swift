//
//  ResgisterView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct ResgisterView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingImagePicker = false
    @State var startAnimate = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        ZStack {
            VStack(spacing: 20){
                
                Button{
                    showingImagePicker.toggle()
                }label: {
                    if let profileImage = loginViewModel.inputImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .frame(width: 170, height: 170)
                        
                        
                    }else{
                        Image(systemName: "person.crop.rectangle")
                            .font(.system(size: 100))
                    }
                }
                
                HStack{
                    Image(systemName: "mail")
                        .font(.system(size: 32))
                        .frame(width: 50)
                    
                    TextField("Email", text: $loginViewModel.email_SignUp)
                    
                }
                .padding(.top, 50)
                HStack{
                    Image(systemName: "lock")
                        .font(.system(size: 32))
                        .frame(width: 50)
                    TextField("Password", text: $loginViewModel.password_SignUp)
                    
                }
                HStack{
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .frame(width: 50)
                    TextField("Re-enter password", text: $loginViewModel.reEnterPassword)
                    
                }
                HStack{
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 32))
                        .frame(width: 50)
                    TextField("First name", text: $loginViewModel.firstName)
                    
                }
                HStack{
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 32))
                        .frame(width: 50)
                    TextField("Last name", text: $loginViewModel.lastName)
                    
                }
                
                Button {
                    print("register")
                    //Register user
                    loginViewModel.registerUser()
                } label:{
                    Text("Register")
                }
                
                
                Spacer()
                
            }
            .padding()
            
            .navigationBarTitle("Register")
            
            
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$loginViewModel.inputImage)
            }
            if loginViewModel.isLoading{
                ProgressView("Registering...")
                    .font(.system(size: 22.0))
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = loginViewModel.inputImage else { return }
        profileImage =  inputImage
    }
}

