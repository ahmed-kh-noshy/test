//
//  CartManager.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 19/11/21.
//

import UIKit
import CoreData

class CartManager {
    
    static let shared = CartManager()
    
    func insertCartItem(product: ProductViewModel, selectedVariantTitle: String, selectedVariantAvailableQuantity: Int, selectedVariantID: String, productImageUrls: [String], productPrice: Decimal, compareAtPrice: Decimal) {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Cart", in: managedContext)!
        
        let item = NSManagedObject(entity: userEntity, insertInto: managedContext)
        item.setValue(product.id, forKey: "productID")
        item.setValue(productPrice, forKey: "productPrice")
        item.setValue(compareAtPrice, forKey: "compareAtPrice")
        item.setValue(product.title, forKey: "productTitle")
        item.setValue(1, forKey: "selectedQuantity")
        item.setValue(selectedVariantAvailableQuantity, forKey: "availableQuantity")
        item.setValue(selectedVariantTitle, forKey: "productVariantTitle")
        item.setValue(selectedVariantID, forKey: "productVariantID")
        item.setValue(productImageUrls, forKey: "productImageUrls")

        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() -> [CartModel] {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        
        var cartDatas: [CartModel] = []
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                cartDatas.append(CartModel(productID: (data.value(forKey: "productID") as? String) ?? "",
                                           productPrice: (data.value(forKey: "productPrice") as? Decimal) ?? 0.0,
                                           compareAtPrice: (data.value(forKey: "compareAtPrice") as? Decimal) ?? 0.0,
                                           productTitle: (data.value(forKey: "productTitle") as? String) ?? "",
                                           selectedQuantity: (data.value(forKey: "selectedQuantity") as? Int) ?? 0,
                                           availableQuantity: (data.value(forKey: "availableQuantity") as? Int) ?? 0,
                                           productVariantTitle: (data.value(forKey: "productVariantTitle") as? String) ?? "",
                                           productVariantID: (data.value(forKey: "productVariantID") as? String) ?? "",
                                           productImageUrls: (data.value(forKey: "productImageUrls") as? [String]) ?? []))
            }
        } catch {
            print("Failed")
        }
        
        return cartDatas
    }
    
    func isProductInCart(product: ProductViewModel, selectedVariantTitle: String) -> Bool {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "productID = %@ AND productVariantTitle = %@", product.id, selectedVariantTitle)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
    
    func deleteCartItem(item: CartModel) {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "productID = %@ AND productVariantTitle = %@", item.productID, item.productVariantTitle)
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
            }
        } catch {
            print("Failed")
        }
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
    
    func deleteAllCartItem() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
            }
        } catch {
            print("Failed")
        }
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
    
    func updateCartItemCount(item: CartModel, count: Int) {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "productID = %@ AND productVariantTitle = %@", item.productID, item.productVariantTitle)
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count > 0 {
                let managedObject = result[0] as! NSManagedObject
                managedObject.setValue(count, forKey: "selectedQuantity")
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    func retrieveWishListData() -> [WishListModel] {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WishList")
        
        var cartDatas: [WishListModel] = []
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                cartDatas.append(WishListModel(productID: (data.value(forKey: "productID") as? String) ?? "",
                                               productPrice: (data.value(forKey: "productPrice") as? String) ?? "",
                                               productTitle: (data.value(forKey: "productTitle") as? String) ?? "",
                                               productImageUrls: (data.value(forKey: "productImageUrls") as? [String]) ?? []))
            }
        } catch {
            print("Failed")
        }
        
        return cartDatas
    }
    
    func insertWishListItem(product: ProductViewModel) {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "WishList", in: managedContext)!
        
        let item = NSManagedObject(entity: userEntity, insertInto: managedContext)
        item.setValue(product.id, forKey: "productID")
        item.setValue(product.price, forKey: "productPrice")
        item.setValue(product.title, forKey: "productTitle")
        item.setValue(product.images.items.map { $0.url.absoluteString }, forKey: "productImageUrls")

        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func isProductInWishList(product: ProductViewModel) -> Bool {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WishList")
        fetchRequest.predicate = NSPredicate(format: "productID = %@", product.id)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
    
    func deleteWishListItem(product: ProductViewModel) {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WishList")
        fetchRequest.predicate = NSPredicate(format: "productID = %@", product.id)
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
            }
        } catch {
            print("Failed")
        }
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
}
