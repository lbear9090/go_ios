//
//  ChatAPI.swift
//  Go
//
//  Created by Lucky on 07/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func conversations(for term: String?, from offset: Int, to limit: Int, completionHandler: ParsingCompletionHandler?) {
        
        var params = [String : Any]()
        
        params[APIKeys.offset] = offset
        params[APIKeys.limit] = limit
        
        if let term = term {
            params["search[term]"] = term
        }
        
        self.loadGETRequest(urlString: APIEndpoints.conversations.versioned,
                            parameters: params,
                            type: Conversation.self,
                            key: APIKeys.conversations,
                            completionHandler: completionHandler)
    }
    
    func conversation(id: Int64, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.conversation, id)
        self.loadGETRequest(urlString: endpoint.versioned,
                            type: Conversation.self,
                            key: APIKeys.conversation,
                            completionHandler: completionHandler)
    }
    
    func messages(_ conversationID: Int64, from: Int = 0, to: Int = 20, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.conversationsMessages, conversationID)
        let params = ["offset": from,
                      "limit": to]
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: Message.self,
                            key: APIKeys.messages,
                            completionHandler: completionHandler)
    }
    
    func send(_ message: Message, to conversation: Conversation, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.conversationsMessages, conversation.id)
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: message.marshaled(),
                             type: Message.self,
                             key: APIKeys.message,
                             completionHandler: completionHandler)
    }
    
    func mute(_ conversation: Conversation, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.muteConversation, conversation.id)
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    func unmute(_ conversation: Conversation, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.muteConversation, conversation.id)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func delete(_ conversation: Conversation, completionHandler: ParsingCompletionHandler?) {
        let endpoint = String(format: APIEndpoints.deleteConversation, conversation.id)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func create(_ conversationRequest: ConversationRequest, completionHandler: ParsingCompletionHandler?) {
        self.loadPOSTRequest(urlString: APIEndpoints.conversations.versioned,
                             parameters: conversationRequest.marshaled(),
                             type: Conversation.self,
                             key: APIKeys.conversation,
                             completionHandler: completionHandler)
    }
    
    func removeParticipant(withId participantId: Int64, from conversationId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.conversationParticipant, conversationId, participantId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func loadParticipants(withId conversationId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.conversationParticipants, conversationId)
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            type: Participant.self,
                            key: APIKeys.participants,
                            completionHandler: completionHandler)
    }
}
