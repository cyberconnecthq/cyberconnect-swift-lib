# CyberConnect

# cyberconnect-swift-lib
cyberconnect-swift-lib is a lib support CyberConnect API, here is an example repo using it
[cyberconnect-swift-example](https://github.com/cyberconnecthq/cyberconnect-swift-example)

## Getting started

### Installation with Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding CyberConnect as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/cyberconnecthq/cyberconnect-swift-lib", .upToNextMajor(from: "1.0.12"))
]
```

### Basic usage

#### Init CyberConnect

```swift
let cyberConnectInstance = CyberConnect(address: YOURWALLETADDRESS)
```

#### Authenticate

Once you get authntication from CyberConnect, you can use CyberConnect to build your own social graphs

```swift
cyberConnectInstance.registerKey(signature: YOURSIGNATURE, network: YOURNETWORKTYPE) { data in
        let dataString = String(decoding: data, as: UTF8.self)
        self.show(UIAlertController(title: "Signature", message: dataString, preferredStyle: .alert))
}
```
- `signature` - The signature of a particular message, you can get the message using, you can sign the message with your own wallet third party wallet:
```swift
let publicKeyPem = cyberconnect.retriveCyberConnectSignKey(address: YOUADDRESS).publicKey.pemRepresentation.pemRepresentationContent()
let message = cyberconnect.getAuthorizeString(localPublicKeyPem: youPublicKeyPem)
```
- `network` - enum type for network, now support ETH and Solana

#### Connect

```swift
cyberConnectInstance.connect(toAddress: SOMEONESADDRESS, alias: ALIAS, network: NETWORK) { data in
        let dataString = String(decoding: data, as: UTF8.self)
        self.show(UIAlertController(title: "Connect", message: dataString, preferredStyle: .alert))
}
```

- `toAddress` - The target wallet address to connect.
- `alias` - (optional) Alias for the target address.
- `network` - (optional) enum type for network, now support ETH and Solana
- `connectionType` - (optional) The type of the connection. The default value is `Connection.FOLLOW`. See [Connection Type](#ConnectionType) for more details.

