//
//  AddressModel.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class AddressModel: Unmarshaling, Codable {
    
    var id: Int64?
    var line1: String?
    var line2: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: CountryModel?
    var active: Bool = false
    var defaultAddress: Bool = false
    
    init() { }
    
    required init(object: MarshaledObject) throws {
        id =                try? object <| "id"
        line1 =             try? object <| "line1"
        line2 =             try? object <| "line2"
        city =              try? object <| "city"
        state =             try? object <| "state"
        postalCode =        try? object <| "postal_code"
        country =           try? object <| "country"
        active =            (try? object <| "active") ?? false
        defaultAddress =    (try? object <| "default") ?? false
    }
    
}

extension AddressModel: Marshaling {

    func marshaled() -> [String: Any] {
        var address = [String: Any]()
    
        address["line1"] = self.line1
        address["line2"] = self.line2
        address["city"] = self.city
        address["state"] = self.state
        address["postal_code"] = self.postalCode
        address["country_code"] = self.country?.alpha2
        
        return address
    }
    
    func validate() -> ValidationState {
        
        guard let line1 = self.line1, !line1.isEmpty else {
            return ValidationState.invalid(error: "ADDRESS_NO_LINE_1".localized)
        }
        guard let city = self.city, !city.isEmpty else {
            return ValidationState.invalid(error: "ADDRESS_NO_TOWN".localized)
        }
        guard let state = self.state, !state.isEmpty else {
            return ValidationState.invalid(error: "ADDRESS_NO_STATE".localized)
        }
        guard let country = self.country?.alpha2, !country.isEmpty else {
            return ValidationState.invalid(error: "ADDRESS_NO_COUNTRY".localized)
        }
        
        return ValidationState.valid
    }
}

