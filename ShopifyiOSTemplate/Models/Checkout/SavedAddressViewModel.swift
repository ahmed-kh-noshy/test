//
//  SavedAddressViewModel.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 26/11/21.
//

import Foundation
import MobileBuySDK

final class SavedAddressViewModel: ViewModel {
    
    typealias ModelType = Storefront.MailingAddressEdge
    
    let model:  ModelType
    
    let firstName:   String?
    let lastName:    String?
    let phone:       String?
    
    let address1:    String?
    let address2:    String?
    let city:        String?
    let country:     String?
    let countryCode: String?
    let province:    String?
    let zip:         String?
    let id:          GraphQL.ID
    let cursor:      String

    // ----------------------------------
    //  MARK: - Init -
    //
    required init(from model: ModelType) {
        self.model       = model
        
        self.firstName   = model.node.firstName
        self.lastName    = model.node.lastName
        self.phone       = model.node.phone
        
        self.address1    = model.node.address1
        self.address2    = model.node.address2
        self.city        = model.node.city
        self.country     = model.node.country
        self.countryCode = model.node.countryCodeV2?.rawValue
        self.province    = model.node.province
        self.zip         = model.node.zip
        self.id          = model.node.id
        self.cursor      = model.cursor
    }
}

extension Storefront.MailingAddressEdge: ViewModeling {
    typealias ViewModelType = SavedAddressViewModel
}
