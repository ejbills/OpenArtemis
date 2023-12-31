//
//  Article Metadata.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/31/23.
//

import LinkPresentation
import SwiftUI
import MobileCoreServices

class LinkViewModel: ObservableObject {
    let metadataProvider = LPMetadataProvider()
    
    @Published var metadata: LPLinkMetadata?
    @Published var image: UIImage?
    
    init(link: String) {
        guard let url = URL(string: link) else {
            return
        }
        metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
            guard error == nil else {
                print("Error: \(error)")
                return
            }
            DispatchQueue.main.async {
                self.metadata = metadata
            }
            
            guard let imageProvider = metadata?.imageProvider else { return }
            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard error == nil else {
                    // Handle error - you may want to set a default image or do something else
                    return
                }
                if let image = image as? UIImage {
                    // Do something with the image
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    print("No image available")
                }
            }
        }
    }
}

struct MetadataView: View {
    @StateObject var vm: LinkViewModel
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Group {
            if vm.image != nil {
                Image(uiImage: vm.image!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .cornerRadius(6)
            } else if vm.metadata != nil {
                // Show a placeholder image or color while loading
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: width, height: height)
                    .cornerRadius(6)
                    .animatedLoading()
            } else {
                // Handle the case when metadata is not available
                Image(systemName: "link")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .cornerRadius(6)
                    .foregroundColor(.gray) // You can customize the color
            }
        }
    }
}
