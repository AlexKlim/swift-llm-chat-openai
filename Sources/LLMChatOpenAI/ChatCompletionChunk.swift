//
//  ChatCompletionChunk.swift
//  LLMChatOpenAI
//
//  Created by Kevin Hermawan on 9/14/24.
//

import Foundation

/// A struct that represents a streamed chunk of a chat completion response.
public struct ChatCompletionChunk: Decodable, Sendable {
    /// A unique identifier for the chat completion. Each chunk has the same identifier.
    public let id: String?
    
    /// An array of chat completion choices. Can contain more than one elements if `n` is greater than 1.
    public var choices: [Choice]
    
    /// The Unix timestamp (in seconds) of when the chat completion was created. Each chunk has the same timestamp.
    public let created: Int
    
    /// The model to generate the completion.
    public let model: String
    
    /// The service tier used for processing the request.
    /// This field is only included if the `serviceTier` parameter is specified in the request.
    public let serviceTier: String?
    
    /// This fingerprint represents the backend configuration that the model runs with.
    /// Can be used in conjunction with the `seed` request parameter to understand when backend changes have been made that might impact determinism.
    public let systemFingerprint: String?
    
    /// The object type, which is always `chat.completion.chunk`.
    public let object: String
    
    /// Usage statistics for the completion request.
    public let usage: Usage?
    
    public struct Choice: Decodable, Sendable {
        /// The index of the choice in the list of choices.
        public let index: Int
        
        /// A chat completion delta generated by streamed model responses.
        public var delta: Delta
        
        /// The reason the model stopped generating tokens.
        /// This will be stop if the model hit a natural `stop` point or a provided stop sequence.
        public let finishReason: FinishReason?
        
        /// Log probability information for the choice.
        public let logprobs: Logprobs?
        
        public struct Delta: Decodable, Sendable {
            /// The role of the author of this message.
            public let role: String?
            
            /// The contents of the message.
            public let content: String?
            
            /// The refusal message generated by the model.
            public let refusal: String?
            
            /// An array of ``ToolCall`` generated by the model.
            public var toolCalls: [ToolCall]?
            
            public struct ToolCall: Decodable, Sendable {
                /// The ID of the tool call.
                public let id: String?
                
                /// The type of the tool. Currently, only `function` is supported.
                public let type: String?
                
                /// The function that the model called.
                public var function: Function?
                
                public struct Function: Decodable, Sendable {
                    /// The name of the function to call.
                    public var name: String?
                    
                    /// The arguments to call the function with, as generated by the model in JSON format.
                    /// Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema.
                    /// Validate the arguments in your code before calling your function.
                    public var arguments: String?
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case role, content, refusal
                case toolCalls = "tool_calls"
            }
        }
        
        /// The reason the model stopped generating tokens.
        public enum FinishReason: String, Decodable, Sendable {
            /// The model reached a natural stop point or a provided stop sequence.
            case stop
            
            /// The maximum number of tokens specified in the request was reached.
            case length
            
            /// The model called a tool.
            case toolCalls = "tool_calls"
            
            /// Content was omitted due to a flag from the content filters.
            case contentFilter = "content_filter"
        }
        
        public struct Logprobs: Decodable, Sendable {
            /// An array of message content tokens with log probability information.
            public let content: [TokenInfo]?
            
            /// An array of message refusal tokens with log probability information.
            public let refusal: [TokenInfo]?
            
            public struct TokenInfo: Decodable, Sendable {
                /// The token.
                public let token: String
                
                /// The log probability of this token, if it is within the top `20` most likely tokens.
                /// Otherwise, the value `-9999.0` is used to signify that the token is very unlikely.
                public let logprob: Double
                
                /// An array of integers representing the UTF-8 bytes representation of the token.
                /// Useful in instances where characters are represented by multiple tokens and their byte representations must be combined to generate the correct text representation.
                /// Can be `nil` if there is no bytes representation for the token.
                public let bytes: [Int]?
                
                /// An array of the most likely tokens and their log probability, at this token position.
                /// In rare cases, there may be fewer than the number of requested `topLogprobs` returned.
                public let topLogprobs: [TokenInfo]?
                
                private enum CodingKeys: String, CodingKey {
                    case token, logprob, bytes
                    case topLogprobs = "top_logprobs"
                }
            }
        }
    }
    
    public struct Usage: Decodable, Sendable {
        /// Number of tokens in the generated completion.
        public let completionTokens: Int?
        
        /// Number of tokens in the prompt.
        public let promptTokens: Int?
        
        /// Total number of tokens used in the request (prompt + completion).
        public let totalTokens: Int?
        
        /// Breakdown of tokens used in a completion.
        public let completionTokensDetails: CompletionTokensDetails?
        
        /// Breakdown of tokens used in the prompt.
        public let promptTokensDetails: PromptTokensDetails?
        
        public struct CompletionTokensDetails: Decodable, Sendable {
            /// When using Predicted Outputs, the number of tokens in the prediction that appeared in the completion.
            public let acceptedPredictionTokens: Int?
            
            /// When using Predicted Outputs, the number of tokens in the prediction that did not appear in the completion.
            /// However, like reasoning tokens, these tokens are still counted in the total completion tokens for purposes of billing, output, and context window limits.
            public let rejectedPredictionTokens: Int?
            
            /// Tokens generated by the model for reasoning.
            public let reasoningTokens: Int?
            
            private enum CodingKeys: String, CodingKey {
                case acceptedPredictionTokens = "accepted_prediction_tokens"
                case reasoningTokens = "reasoning_tokens"
                case rejectedPredictionTokens = "rejected_prediction_tokens"
            }
        }
        
        public struct PromptTokensDetails: Decodable, Sendable {
            /// Cached tokens present in the prompt.
            public let cachedTokens: Int
            
            private enum CodingKeys: String, CodingKey {
                case cachedTokens = "cached_tokens"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case completionTokens = "completion_tokens"
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
            case completionTokensDetails = "completion_tokens_details"
            case promptTokensDetails = "prompt_tokens_details"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, choices, created, model
        case serviceTier = "service_tier"
        case systemFingerprint = "system_fingerprint"
        case object, usage
    }
}
