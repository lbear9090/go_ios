//
//  ConfigurationsModel.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class ConfigurationsModel: Unmarshaling, Codable {
    
    var countries: [CountryModel]
    var idTypes: [IdNameModel]
    var currencies: [CurrencyModel]
    var termsUrl: String?
    var privacyPolicyUrl: String?
    var supportUrl: String?

    required init(object: MarshaledObject) throws {
        countries =     (try? object <| "countries") ?? []
        idTypes =       (try? object <| "identification_types") ?? []
        currencies =    (try? object <| "currencies") ?? []
        termsUrl =          try? object <| "urls.terms"
        privacyPolicyUrl =  try? object <| "urls.privacy_policy"
        supportUrl =        try? object <| "urls.support"
    }
}
