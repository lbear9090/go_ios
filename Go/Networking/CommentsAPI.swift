//
//  CommentsAPI.swift
//  Go
//
//  Created by Lucky on 22/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func getComments(eventId: Int64,
                     timelineId: Int64,
                     offset: Int,
                     limit: Int,
                     completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.timelineComments, eventId, timelineId)
        let params = [APIKeys.offset: offset,
                      APIKeys.limit: limit]
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: CommentModel.self,
                            key: APIKeys.comments,
                            completionHandler: completionHandler)
    }
    
    func createComment(withText text: String,
                       eventId: Int64,
                       timelineId: Int64,
                       completionHandler: @escaping ParsingCompletionHandler) {

        let endpoint = String(format: APIEndpoints.timelineComments, eventId, timelineId)
        let params = ["comment": ["content": text]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: CommentModel.self,
                             key: APIKeys.comment,
                             completionHandler: completionHandler)
    }
    
    func deleteComment(withId commentId: Int64,
                       eventId: Int64,
                       timelineId: Int64,
                       completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.deleteComment, eventId, timelineId, commentId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func reportComment(withId commentId: Int64,
                       eventId: Int64,
                       timelineId: Int64,
                       reason: ReportReason,
                       completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.reportComment, eventId, timelineId, commentId)
        let params = [APIKeys.report: [APIKeys.reportReason: reason.rawValue]]

        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }

}
