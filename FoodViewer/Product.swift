//
//  Product.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import MapKit

class FoodProduct {
    
    
    // Primary variables
    
    // MARK: - Identification variables
    
    var barcode: BarcodeType
    
    var name: String? = nil {
        didSet {
            // make sure things are consistent
            // add the name also to the name languages array
            setName()
        }
    }
    
    private func setName() {
        if primaryLanguageCode != nil && name != nil {
            nameLanguage[primaryLanguageCode!] = name
        }
    }
    
    var nameLanguage = [String:String?]() {
        didSet {
            if let language = primaryLanguageCode,
                let validName = name,
                let existingLanguageName = nameLanguage[language],
                let validLanguageName = existingLanguageName {
                if  validLanguageName != validName {
                    print("Product Error: names are not consistent")
                }
            }
        }
    }


    var genericName: String? = nil {
        didSet {
            // make sure things are consistent
            setGenericName()
        }
    }
    
    private func setGenericName() {
        if primaryLanguageCode != nil && genericName != nil {
            genericNameLanguage[primaryLanguageCode!] = genericName
        }
    }
    
    var genericNameLanguage = [String:String?]() {
        didSet {
            if let language = primaryLanguageCode,
                let validName = genericName,
                let existingLanguageName = genericNameLanguage[language],
                let validLanguageName = existingLanguageName {
                if  validLanguageName != validName {
                    print("Product Error: generic names are not consistent")
                }
            }
        }
    }

    var brands: Tags = .undefined
    var mainUrlThumb: URL? {
        didSet {
            if let imageURL = mainUrlThumb {
                do {
                    let imageData = try Data(contentsOf: imageURL, options: NSData.ReadingOptions.mappedIfSafe)
                    if imageData.count > 0 {
                        mainImageSmallData = imageData
                    }
                }
                catch {
                    print(error)
                }
            }
        }
     }

    var mainImageSmallData: Data? = nil

    var mainImageUrl: URL? = nil
    var mainImageData: ImageFetchResult? = nil {
        didSet {
            if mainImageData != nil {
                NotificationCenter.default.post(name: .MainImageSet, object:nil)
            }
        }
    }
    
    var primaryLanguageCode: String? = nil {
        didSet {
            // make sure things are consistent
            setName()
            setGenericName()
            if let validLanguage = primaryLanguageCode {
                if !languageCodes.contains(validLanguage) {
                    languageCodes.append(validLanguage)
                    // TBD need to add to language array
                }
            }
        }
    }
    var languageCodes: [String] = []
    
    var languages: [String:String] {
        get {
            var languageList: [String:String] = [:]
            for languageCode in self.languageCodes {
                // TBD can this be set in the locale language?
                languageList[languageCode] = OFFplists.manager.translateLanguage(languageCode, language: "en")
            }
            return languageList
        }
    }
    
    // MARK: - Packaging variables
    
    var quantity: String? = nil
    var packagingArray: Tags = .undefined
    
    // MARK: - Ingredients variables
    
    var ingredients: String? {
        didSet {
            // make sure things are consistent
            // add the name also to the name languages array
            setIngredients()
        }
    }
    
    private func setIngredients() {
        if primaryLanguageCode != nil && ingredients != nil {
            ingredientsLanguage[primaryLanguageCode!] = ingredients
        }
    }

    var ingredientsLanguage = [String:String]()
    
    var numberOfIngredients: String? = nil
    var imageIngredientsSmallUrl: URL?
    var imageIngredientsUrl: URL? = nil
    var ingredientsImageData: ImageFetchResult? = nil {
        didSet {
            if ingredientsImageData != nil {
                NotificationCenter.default.post(name: .IngredientsImageSet, object: nil)
            }
        }
    }
    // This includes the language prefix en:
    var allergenKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var translatedAllergens: Tags {
        get {
            if let validAllergenKeys = allergenKeys {
                var translatedAllergens:[String] = []
                let preferredLanguage = Locale.preferredLanguages[0]
                for allergenKey in validAllergenKeys {
                    if let translatedKey = OFFplists.manager.translateAllergens(allergenKey, language:preferredLanguage) {
                        translatedAllergens.append(translatedKey)
                    } else {
                        translatedAllergens.append(allergenKey)
                    }
                }
                return translatedAllergens.count == 0 ? .empty : .available(translatedAllergens)
            }
            return .undefined
        }
    }
    
    var allergens: Tags = .undefined
    
    var traceKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var translatedTraces: Tags {
        get {
            if let validTracesKeys = traceKeys {
                var translatedTraces:[String] = []
                let preferredLanguage = Locale.preferredLanguages[0]
                for tracesKey in validTracesKeys {
                    if let translatedKey = OFFplists.manager.translateAllergens(tracesKey, language:preferredLanguage) {
                        translatedTraces.append(translatedKey)
                    } else {
                        translatedTraces.append(tracesKey)
                    }
                }
                return translatedTraces.count == 0 ? .empty : .available(translatedTraces)
            }
            return .undefined
        }
    }

    var traces: Tags = .undefined
    
    var additives: Tags = .undefined
    var labelArray: Tags = .undefined
    
    // usage parameters
    var servingSize: String? = nil
    
    // MARK: - Nutrition variables 
    
    var nutritionFactsAreAvailable: NutritionAvailability {
        get {
            // Figures out whether a nutrition fact contains values per serving and/or standard
            if let validNutritionFacts = nutritionFacts {
                if !validNutritionFacts.isEmpty {
                    if validNutritionFacts[0]?.servingValue != nil &&
                        !validNutritionFacts[0]!.servingValue!.isEmpty &&
                        validNutritionFacts[0]?.standardValue != nil &&
                        !validNutritionFacts[0]!.standardValue!.isEmpty {
                        return .perServingAndStandardUnit
                    } else if validNutritionFacts[0]?.servingValue != nil &&
                        !validNutritionFacts[0]!.servingValue!.isEmpty {
                        return .perServing
                    } else if validNutritionFacts[0]?.standardValue != nil &&
                        !validNutritionFacts[0]!.standardValue!.isEmpty {
                        return .perStandardUnit
                    }
                }
            }
            return .notIndicated
        }
    }
    
    // This variable indicates whether there are nutrition facts available on the package.
    var hasNutritionFacts: Bool? = nil // nil indicates that it is not known
    
    // hasNutritionFacts can be nil even if there are nutriments defined
    var nutrimentFactsAvailability: Bool {
        get {
            if hasNutritionFacts != nil {
                return hasNutritionFacts!
            } else {
                return nutritionFacts != nil || nutritionFactsImageUrl != nil ? true : false
            }
        }
    }
    var nutritionFactsIndicationUnit: NutritionEntryUnit? = nil
    
    // The nutritionFacts array can be nil, if nothing has been defined
    // An element in the array can be nil as well
    var nutritionFacts: [NutritionFactItem?]? = nil
    
    func add(fact: NutritionFactItem) {
        if nutritionFacts == nil {
            nutritionFacts = []
        }
        nutritionFacts?.append(fact)
        
    }
    
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: URL? = nil
    var nutritionFactsImageUrl: URL? = nil
    var nutritionImageData: ImageFetchResult? {
        didSet {
            if nutritionImageData != nil {
                NotificationCenter.default.post(name: .NutritionImageSet, object: nil)
            }
        }
    }
    
    func getNutritionImageData() -> ImageFetchResult? {
        if nutritionImageData == nil {
            nutritionImageData = .loading
            // launch the image retrieval
            nutritionImageData?.retrieveImageData(nutritionFactsImageUrl) { (fetchResult:ImageFetchResult?) in
                self.nutritionImageData = fetchResult
            }
        }
        return nutritionImageData
    }
    
    func getMainImageData() -> ImageFetchResult {
        if mainImageData == nil {
            // launch the image retrieval
            mainImageData = .loading
            mainImageData?.retrieveImageData(mainImageUrl) { (fetchResult:ImageFetchResult?) in
                self.mainImageData = fetchResult
            }
        }
        return mainImageData!
    }

    func getIngredientsImageData() -> ImageFetchResult {
        if ingredientsImageData == nil {
            // launch the image retrieval
            ingredientsImageData = .loading
            ingredientsImageData?.retrieveImageData(imageIngredientsUrl) { (fetchResult:ImageFetchResult?) in
                self.ingredientsImageData = fetchResult
            }
        }
        return ingredientsImageData!
    }

    
    //MARK: - Supply chain variables
    
    var nutritionGrade: NutritionalScoreLevel? = nil
    var nutritionalScoreUK = NutritionalScoreUK()
    var nutritionalScoreFrance = NutritionalScoreFrance()
    var purchaseLocation: Address? = nil //or a set?
    
    func purchaseLocationElements(_ elements: [String]?) {
        if elements != nil {
            if self.purchaseLocation == nil {
                self.purchaseLocation = Address()
            }
            self.purchaseLocation?.rawArray = clean(elements!)
        }
    }
    
    func purchaseLocationString(_ location: String?) {
        if let validLocationString = location {
            self.purchaseLocation = Address()
            self.purchaseLocation!.locationString = validLocationString
        }
    }
    
    var stores: [String]? = nil {
        didSet {
            if stores != nil {
                self.stores = clean(stores!)
            }
        }
    }
    
    var countries: [Address]? = nil //or a set?
    
    func countryArray(_ countries:[String]?) {
        if let array = countries {
            if !array.isEmpty {
                for element in array {
                    if !element.isEmpty {
                        if self.countries == nil {
                            self.countries = []
                        }
                        let newAddress = Address()
                        newAddress.country = element
                        self.countries!.append(newAddress)
                    }
                }
            } else {
                self.countries = []
            }
        }
    }

    var producer: Address? = nil
    
    var links: [URL]? = nil
    
    var expirationDateString: String? = nil

    var expirationDate: Date? {
        get {
            return decodeDate(expirationDateString)
        }
    }
    
    fileprivate func decodeDate(_ date: String?) -> Date? {
        if let validDate = date {
            if !validDate.isEmpty {
                let types: NSTextCheckingResult.CheckingType = [.date]
                let dateDetector = try? NSDataDetector(types: types.rawValue)
                
                let dateMatches = dateDetector?.matches(in: validDate, options: [], range: NSMakeRange(0, (validDate as NSString).length))
                
                if let matches = dateMatches {
                    if !matches.isEmpty {
                        // did we find a date?
                        if matches[0].resultType == NSTextCheckingResult.CheckingType.date {
                            return matches[0].date
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                // This is for formats not recognized by NSDataDetector
                // such as 07/2014
                // but other formats are possible and still need to be found
                if validDate.range( of: "../....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: ".-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: "0"+validDate)
                } else if validDate.range( of: "..-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM-yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: "....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "yyyy"
                    return dateFormatter.date(from: validDate)
                }
                print("Date '\(validDate)' could not be recognized")
            }
        }
        return nil
    }

    func producerElements(_ elements: String?) {
        if elements != nil {
            let addressElements = elements?.characters.split{$0 == ","}.map(String.init)
            self.producer = Address()
            self.producer!.rawArray = addressElements
        }
    }
    
    func producerElementsArray(_ elements: [String]?) {
        if let validElements = elements {
            self.producer = Address()
            self.producer!.rawArray = validElements
        }
    }
    var ingredientsOrigin: Address? = nil
    
    func ingredientsOriginElements(_ elements: [String]?) {
        self.ingredientsOrigin = Address()
        self.ingredientsOrigin!.rawArray = elements
    }

    var producerCode: [Address]? = nil
    
    var producerCodeArray: [String]? = nil {
        didSet {
            if let validProducerCodes = producerCodeArray {
                producerCode = []
                for code in validProducerCodes {
                    let newAddress = Address()
                    newAddress.raw = code
                    producerCode?.append(newAddress)
                }
            }
        }
    }
    
    // remove any empty items from the list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }

    // contributor parameters
    var additionDate: Date? = nil
    var lastEditDates: [Date]? = nil
    var creator: String? = nil {
        didSet {
            if let user = creator {
                if !productContributors.contains(user) {
                    productContributors.add(user)
                }
                productContributors.contributors[productContributors.indexOf(user)!].role.isCreator = true
                contributorsArray.append((ContributorTypes.CreatorKey, [user]))
            }
        }
    }
    var state = CompletionState()
    

    // group parameters
    var categories: Tags = .undefined
    
    // community parameters
    var photographers: [String]? = nil {
        didSet {
            if let users = photographers {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isPhotographer = true
                }
                contributorsArray.append((ContributorTypes.PhotographersKey, users))
            }
        }
    }
    
    // community parameters
    var correctors: [String]? = nil {
        didSet {
            if let users = correctors {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isCorrector = true
                }
                contributorsArray.append((ContributorTypes.PhotographersKey, users))
            }
        }
    }

    
    var editors: [String]? = nil {
        didSet {
            if let users = editors {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isEditor = true
                }
                contributorsArray.append((ContributorTypes.EditorsKey, users))
            }
        }
    }

    var informers: [String]? = nil {
        didSet {
            if let users = informers {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isInformer = true
                }
                contributorsArray.append((ContributorTypes.InformersKey, users))
            }
        }
    }
    
    var productContributors = UniqueContributors()
    
    
    var contributorsArray: [(String,[String]?)] = []

    
    struct UniqueContributors {
        var contributors: [Contributor] = []
        
        func indexOf(_ name: String) -> Int? {
            for index in 0 ..< contributors.count {
                if contributors[index].name == name {
                    return index
                }
            }
            return nil
        }
        
        func contains(_ name: String) -> Bool {
            return indexOf(name) != nil ? true : false
        }
        
        mutating func add(_ name: String) {
            contributors.append(Contributor(name: name, role: ContributorRole()))
        }
    }

    
    struct Contributor {
        var name: String
        var role: ContributorRole
    }
    
    struct ContributorRole {
        var isPhotographer: Bool = false
        var isCreator: Bool = false
        var isCorrector: Bool = false
        var isEditor: Bool = false
        var isInformer: Bool = false
    }
        
    struct ContributorTypes {
        static let CheckersKey = "Checkers"
        static let InformersKey = "Informers"
        static let EditorsKey = "Editors"
        static let PhotographersKey = "Photographers"
        static let CreatorKey = "Creator"
        static let CorrectorKey = "Correctors"
    }
    
    // MARK: - Initialize functions
    
    init() {
        barcode = BarcodeType.undefined("")
        name = nil
        genericName = nil
        brands = .undefined
        mainUrlThumb = nil
        mainImageUrl = nil
        mainImageData = nil
        packagingArray = .undefined
        quantity = nil
        ingredients = nil
        imageIngredientsSmallUrl = nil
        imageIngredientsUrl = nil
        allergenKeys = nil
        traceKeys = nil
        additives = .undefined
        labelArray = .undefined
        producer = nil
        ingredientsOrigin = nil
        producerCode = nil
        servingSize = nil
        nutritionFacts = []
        nutritionScore = nil
        imageNutritionSmallUrl = nil
        nutritionFactsImageUrl = nil
        nutritionGrade = nil
        purchaseLocation = nil
        stores = nil
        countries = nil
        additionDate = nil
        creator = nil
        state = CompletionState()
        primaryLanguageCode = nil
        categories = .undefined
        photographers = nil
        correctors = nil
        editors = nil
        informers = nil
        hasNutritionFacts = nil
        productContributors = UniqueContributors()
        contributorsArray = []
    }
    
    init(withBarcode: BarcodeType) {
        self.barcode = withBarcode
    }
    
    init(product: FoodProduct) {
        self.barcode = product.barcode
        self.primaryLanguageCode = product.primaryLanguageCode
        // self.languageCodes = product.languageCodes

    }
    
    func nutritionFactsContain(_ nutritionFactToCheck: String) -> Bool {
        if let validNutritionFacts = self.nutritionFacts {
            for fact in validNutritionFacts {
                if fact != nil && fact!.itemName == nutritionFactToCheck {
                    return true
                }
            }

        }
        return false
    }
    
    /*
    private func retrieveImageData(url: NSURL?, cont: ((ImageFetchResult?) -> Void)?) {
        if let imageURL = url {
            // self.nutritionImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.Success(imageData))
                            return
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.NoData)
                            return
                        })
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        cont?(.LoadingFailed(error))
                        return
                    })
                }
            })
        } else {
            cont?(.NoData)
            return
        }
    }

    private func retrieveMainImageData() {
        if let imageURL = mainUrl {
            self.mainImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.mainImageData = .Success(imageData)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.mainImageData = .NoData
                        })
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        self.mainImageData = .LoadingFailed(error)
                    })
                }
            })
        } else {
            self.mainImageData = .NoData
        }
    }

    private func retrieveIngredientsImageData() {
        if let imageURL = imageIngredientsUrl {
            self.ingredientsImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.ingredientsImageData = .Success(imageData)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.ingredientsImageData = .NoData
                        })

                    }
                    
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        self.ingredientsImageData = .LoadingFailed(error)
                    })
                }
            })
        } else {
            self.mainImageData = .NoData

        }
    }
     */
    
    // updates a product with new product data
    func updateDataWith(_ product: FoodProduct) {
        // all image data is set to nil, in order to force a reload
        
        // is it really the same product?
        if barcode.asString() == product.barcode.asString() {
            // Do I need to replace things, or should I carry out a check first?
            name = product.name
            nameLanguage = product.nameLanguage
            genericName = product.genericName
            genericNameLanguage = product.genericNameLanguage
            brands = product.brands
            mainUrlThumb = product.mainUrlThumb
            mainImageUrl = product.mainImageUrl
            mainImageData = nil
            packagingArray = product.packagingArray
            quantity = product.quantity
            ingredients = product.ingredients
            ingredientsLanguage = product.ingredientsLanguage
            imageIngredientsSmallUrl = product.imageIngredientsSmallUrl
            imageIngredientsUrl = product.imageIngredientsUrl
            ingredientsImageData = nil
            numberOfIngredients = product.numberOfIngredients
            allergenKeys = product.allergenKeys
            traceKeys = product.traceKeys
            additives = product.additives
            labelArray = product.labelArray
            producer = product.producer
            ingredientsOrigin = product.ingredientsOrigin
            producerCode = product.producerCode
            servingSize = product.servingSize
            nutritionFacts = product.nutritionFacts
            nutritionScore = product.nutritionScore
            imageNutritionSmallUrl = product.imageNutritionSmallUrl
            nutritionFactsImageUrl = product.nutritionFactsImageUrl
            nutritionImageData = nil
            nutritionGrade = product.nutritionGrade
            purchaseLocation = product.purchaseLocation
            stores = product.stores
            countries = product.countries
            additionDate = product.additionDate
            expirationDateString = product.expirationDateString
            creator = product.creator
            state = product.state
            primaryLanguageCode = product.primaryLanguageCode
            languageCodes = product.languageCodes
            categories = product.categories
            photographers = product.photographers
            correctors = product.correctors
            editors = product.editors
            informers = product.informers
            productContributors = product.productContributors
            contributorsArray = product.contributorsArray
            hasNutritionFacts = product.hasNutritionFacts
            // did I miss something?
        }
    }
    
    func worldURL() -> URL? {
        return URL(string: "http://world.openfoodfacts.org/product/" + barcode.asString() + "/")
    }
    
    func regionURL() -> URL? {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        return URL(string: "http://\(region).openfoodfacts.org/en:product/" + barcode.asString() + "/")
    }
    
    func add(shop: String?) -> [String]? {
        if let validShop = shop {
            // are there any shops yet?
            if let validStores = stores {
                // is this shop not listed?
                if !validStores.contains(validShop) {
                    // there might be a shop with an empty string
                    if validStores.count == 1 && validStores[0].characters.count == 0 {
                        stores = [validShop]
                    } else {
                        stores!.append(validShop)
                    }
                }
            } else {
                // add the first shop
                stores = [validShop]
            }
        }
        return stores
    }
    
    func set(newName: String, for languageCode: String) {
        // is this the main language?
        if languageCode == self.primaryLanguageCode {
            self.name = newName
        }
        add(languageCode: languageCode)
        self.nameLanguage[languageCode] = newName
    }
    
    func set(newGenericName: String, for languageCode: String) {
        // is this the main language?
        if languageCode == self.primaryLanguageCode {
            self.genericName = newGenericName
        }
        add(languageCode: languageCode)
        self.genericNameLanguage[languageCode] = newGenericName
    }

    func set(newIngredients: String, for languageCode: String) {
        add(languageCode: languageCode)
        self.ingredientsLanguage[languageCode] = newIngredients
        if languageCode == self.primaryLanguageCode {
            self.ingredients = newIngredients
        }
    }

    func add(languageCode: String) {
        // is this a new language?
        if !self.languageCodes.contains(languageCode) {
            self.languageCodes.append(languageCode)
        }
    }
    
    func contains(name: String, for languageCode: String) -> Bool {
        if nameLanguage[languageCode] != nil, nameLanguage[languageCode]! == name {
            return true
        }
        return false
    }
    
    func contains(genericName: String, for languageCode: String) -> Bool {
        if genericNameLanguage[languageCode] != nil, genericNameLanguage[languageCode]! == name {
            return true
        }
        return false
    }
    
    func contains(ingredients: String) -> Bool {
        return ingredients == self.ingredients ? true : false
    }
    
    func contains(servingSize: String) -> Bool {
        return servingSize == self.servingSize ? true : false
    }
    
    func contains(expirationDate: Date) -> Bool {
        return expirationDate == self.expirationDate ? true : false
    }

    func contains(expirationDateString: String) -> Bool {
        return expirationDateString == self.expirationDateString ? true : false
    }

    func contains(primaryLanguageCode: String) -> Bool {
        return primaryLanguageCode == self.primaryLanguageCode ? true : false
    }

    func contains(languageCode: String) -> Bool {
        return languageCodes.contains(languageCode) ? true : false
    }

    func contains(shop: String) -> Bool {
        guard stores != nil else { return false }
        return stores!.contains(shop) ? true : false
    }
    
    func contains(brands: [String]) -> Bool {
        switch self.brands {
        case .available(let currentBrands):
            return Set.init(currentBrands) == Set.init(brands) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(packaging: [String]) -> Bool {
        switch self.packagingArray {
        case .available(let currentpackagingArray):
            return Set.init(currentpackagingArray) == Set.init(packaging) ? true : false
        default:
            break
        }
        return false
    }

    func contains(traces: [String]) -> Bool {
        switch self.traces {
        case .available(let currentTraces):
            return Set.init(currentTraces) == Set.init(traces) ? true : false
        default:
            break
        }
        return false
    }

    func contains(labels: [String]) -> Bool {
        switch self.labelArray {
        case .available(let currentLabels):
            return Set.init(currentLabels) == Set.init(labels) ? true : false
        default:
            break
        }
        return false
    }

    func contains(categories: [String]) -> Bool {
        switch self.categories {
        case .available(let currentCategories):
            return Set.init(currentCategories) == Set.init(categories) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(producer: [String]) -> Bool {
        if let validProducerArray = self.producer?.elements {
            return Set.init(validProducerArray) == Set.init(producer) ? true : false
        }
        return false
    }

    func contains(producerCode: [String]) -> Bool {
        // assume that the producerCode only contains a raw
        if let validProducerCodeArray = self.producerCode?.map( { $0.raw } ) {
            return Set.init(validProducerCodeArray) == Set.init(producerCode) ? true : false
        }
        return false
    }

    func contains(ingredientsOrigin: [String]) -> Bool {
        if let validIngredientsOriginArray = self.ingredientsOrigin?.elements {
            return Set.init(validIngredientsOriginArray) == Set.init(ingredientsOrigin) ? true : false
        }
        return false
    }
    
    func contains(stores: [String]) -> Bool {
        if let validStoresArray = self.stores {
            return Set.init(validStoresArray) == Set.init(stores) ? true : false
        }
        return false
    }

    func contains(purchaseLocation: [String]) -> Bool {
        if let validPurchaseLocationArray = self.purchaseLocation?.elements {
            return Set.init(validPurchaseLocationArray) == Set.init(purchaseLocation) ? true : false
        }
        return false
    }
    
    func contains(countries: [String]) -> Bool {
        if let validCountriesArray = self.countries?.map( { $0.title } ) {
            return Set.init(validCountriesArray) == Set.init(countries) ? true : false
        }
        return false
    }

    func contains(links: [String]) -> Bool {
        if let validLinksArray = self.links?.map( { $0.absoluteString } ) {
            return Set.init(validLinksArray) == Set.init(links) ? true : false
        }
        return false
    }

    func contains(quantity: String) -> Bool {
        return quantity == self.quantity ? true : false
    }

    func contains(availability: Bool) -> Bool {
        return availability == self.hasNutritionFacts ? true : false
    }

// End product
}

// Definition:
extension Notification.Name {
    static let MainImageSet = Notification.Name("FoodProduct.Notification.MainImageSet")
    static let IngredientsImageSet = Notification.Name("FoodProduct.Notification.IngredientsImageSet")
    static let NutritionImageSet = Notification.Name("FoodProduct.Notification.NutritionImageSet")
}

