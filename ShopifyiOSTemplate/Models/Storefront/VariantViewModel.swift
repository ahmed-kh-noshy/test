//
//  VariantViewModel.swift
//  Storefront
//
//  Created by Shopify.
//  Copyright (c) 2017 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import MobileBuySDK
import UIKit

final class VariantViewModel: ViewModel {
    
    typealias ModelType = Storefront.ProductVariantEdge
    
    let model:  ModelType
    let cursor: String
    
    let id:     String
    let title:  String
    let price:  Decimal
    let compareAtPrice: Decimal?
    let availableForSale: Bool
    let availableQuantity: Int

    // ----------------------------------
    //  MARK: - Init -
    //
    required init(from model: ModelType) {
        self.model  = model
        self.cursor = model.cursor
        
        self.id     = model.node.id.rawValue
        self.title  = model.node.title
        self.price  = model.node.priceV2.amount
        self.compareAtPrice = model.node.compareAtPriceV2?.amount
        self.availableForSale = model.node.availableForSale
        self.availableQuantity = Int(model.node.quantityAvailable ?? 0)
    }
    
    func formattedPriceString() -> NSMutableAttributedString {
        return Utils.formattedPriceString(price: price, compareAtPrice: compareAtPrice)
    }
}

extension Storefront.ProductVariantEdge: ViewModeling {
    typealias ViewModelType = VariantViewModel
}
