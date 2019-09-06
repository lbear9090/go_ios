//
//  IdentificationRequestModel.swift
//  Go
//
//  Created by Lucky on 14/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

struct IdentificationRequestModel: Marshaling {
    
    var typeId: Int64?
    var idNumber: String?
    var frontImage: UIImage?
    var backImage: UIImage?
    var frontImageUrl: String?
    var backImageUrl: String?
    
    func marshaled() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["identification_type_id"] = typeId
        dict["identification_number"] = idNumber
        dict["front_image_url"] = frontImageUrl
        dict["back_image_url"] = backImageUrl

        return ["identification": dict]
    }
    
    func validate() -> ValidationState {
        
        guard self.typeId != nil else {
            return .invalid(error: "VERIFY_ID_NO_TYPE".localized)
        }
        guard let idNumber = self.idNumber, !idNumber.isEmpty else {
            return .invalid(error: "VERIFY_ID_NO_NUMBER".localized)
        }
        guard self.frontImage != nil else {
            return .invalid(error: "VERIFY_ID_NO_FRONT_IMAGE".localized)
        }
        guard self.backImage != nil else {
            return .invalid(error: "VERIFY_ID_NO_BACK_IMAGE".localized)
        }
        
        return .valid
    }
}
