# UnitTestingNetworkWithStub_Demo

### About

This is a sample demo on how to build a simple and tested network suite using just vanila Foundation and the power of Swift programming language. Only to use `Mockingjay` third party library for network stub in unit test. This can be improved.

0. Show how easy it is to design a model using `Codable` protocol from Swift 4+. So we no longer need to use any third party model mapping library, now that the Swift compiler will take care of it. Check [`User`](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2/Model/User.swift) and [`Repository`](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2/Model/Repository.swift) model. 
1. Show how to design a clean and generic [`NetworkRequest`](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2/Network/NetworkRequest.swift) protocol that taking care of constructing the endpoint and handle network request, then serialize the data response into model using `URLSession`. [`Conformers`](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2/Network/GithubUserRequest.swift) just need to conform to `NetworkRequest` protocol and take advantage of Swift default protocol implementation, it can be [customizable](https://github.com/vinhnx/iOS-notes/issues/47).
2. Write test cases for [NetworkRequest](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2Tests/NetworkRequestTests.swift) and our [model](https://github.com/vinhnx/UnitTestingNetworkWithStub_Demo/blob/master/UnitTestingNetworkWithStub_2Tests/UserTests.swift) using `XCTest` and `Mockingjay` for network stub.

### TODO 

+ Note to self: learn about `URLProtocol` to write a DIY network stub to even not using `Mockingjay` 🤔
+ UI testing

### References

- https://api.github.com/users/{user_name}
- https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
- https://www.swiftbysundell.com/posts/writing-unit-tests-in-a-swift-playground
- http://hoangtran.me/ios/testing/2016/09/12/unit-test-network-layer-in-ios/
- https://useyourloaf.com/blog/swift-codable-with-custom-dates/
