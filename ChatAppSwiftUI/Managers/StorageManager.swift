//
//  StorageManager.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import FirebaseStorage

class StorageManager{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result<String,Error>)-> Void
    
    func uploadProfilePicture(with data: Data, fileName: String, completionHandler: @escaping UploadPictureCompletion){
        
        storage.child(fileName).putData(data, metadata: nil) { storageMetaData, error in
            
            guard error == nil else{
                completionHandler(.failure(StorageError.failedUpload))
                return
            }
            
            self.downloadURL(for: fileName) { result in
                switch result{
                case .success(let url):
                    let urlString = url.absoluteString
                    completionHandler(.success(urlString))
                case .failure(let error):
                    print("Error\(error)")
                    completionHandler(.failure(error))
                
                }
            }
            
            
        }
        
    }
    func downloadURL(for path: String, completion: @escaping (Result<URL,Error>)->Void){
        self.storage.child(path).downloadURL { downloadUrl, error in
            print(path)
            guard let url = downloadUrl else{
                completion(.failure(StorageError.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        }
    }
    
    
    
    enum StorageError: Error{
        case failedUpload
        
        case failedToGetDownloadURL
    }
    
    

}
