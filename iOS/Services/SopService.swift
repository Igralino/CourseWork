import Foundation
import web3swift
import BigInt
import SwiftKeychainWrapper

class SopService {
    
    private let storeContainer: StoreContainer = KeychainWrapper(serviceName: "group.ru.hse.userCache")
    
    func saveKeys(publicKey: String, privateKey: String) {
        privateKeyStorage[publicKey] = privateKey
    }
    
    private var privateKeyStorage: [String: String] {
        get {
            return storeContainer.get(key: "SopService.privateKeyStorage") ?? [:]
        }
        set {
            storeContainer.store(data: newValue, key: "SopService.privateKeyStorage")
        }
    }
    
    var privateKey: String? {
        return privateKeyStorage[signingPublicKey]
    }
    
    init(user: Voting.MeResponse) {
        self.signingPublicKey = user.publicKey ?? ""
        self.contractAddress = user.contractTx
    }

    private var userWalletAddress: String {
        return privateKey ?? "" // transform somehow
    }
    
    private let contractAddress: String
    private let signingPublicKey: String

    private var contract: web3.web3contract!
    private var transactionOptions: TransactionOptions!
    private var web3 = Web3.InfuraRinkebyWeb3()
    private var keystoreManager: KeystoreManager?

    private func setUpWeb3(with walletKey: String) {
        let password = "web3swift"

        // TODO: Get from user input
        let formattedKey = walletKey.trimmingCharacters(in: .whitespacesAndNewlines)

        let dataKey = Data.fromHex(formattedKey) ?? Data()
        if let keystore = try? EthereumKeystoreV3(privateKey: dataKey, password: password) {
            keystoreManager = KeystoreManager([keystore])
            web3.addKeystoreManager(keystoreManager)
        }



        let contractABI = contractAbi
        let contractAddress = EthereumAddress(contractAddress)!
        let abiVersion = 2
        contract = web3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!


        var options = TransactionOptions.defaultOptions
        options.gasPrice = .manual(BigUInt(8750000000))
        options.gasLimit = .manual(BigUInt(30000000))

        if let address = EthereumAddress(keystoreManager?.addresses?.first?.address ?? "") {
            options.from = address
        }

        transactionOptions = options

    }
    
    func testGetVotingName(walletKey: String, completion: (String) -> ()) {
        setUpWeb3(with: walletKey)
        let contractMethod = "name"
        let tx = contract.read(
            contractMethod,
            parameters: [],
            extraData: Data(),
            transactionOptions: transactionOptions)!

        guard let callRes = try? tx.call(),
              let name = callRes["0"] as? String else {
            return
        }
        completion(name)
    }

       private func getVotersPublicKeys() throws {
           let contractMethod = "get_voters_public_keys"

           let tx = contract.read(
               contractMethod,
               parameters: [],
               extraData: Data(),
               transactionOptions: transactionOptions)!

           guard let callRes = try? tx.call(),
                 let publicKeys = callRes["0"] as? [String] else {
               throw "Incorrect data"
           }
           print(publicKeys) // Used to create and sign Ring Signature
       }

       private func getVotingName() throws {
           let contractMethod = "name"

           let tx = contract.read(
               contractMethod,
               parameters: [],
               extraData: Data(),
               transactionOptions: transactionOptions)!

           guard let callRes = try? tx.call(),
                 let name = callRes["0"] as? String else {
               throw "Incorrect data"
           }
           print(name) // Just a name of voting from smartContract
       }

       private func sendVote() throws {

           let contractMethod = "vote"

           var vote = Dictionary<String, String>()
           vote["difficulty"] = "Slozno"
           vote["profit"] =  "Klassno"

           let encoder = JSONEncoder()
           let jsonData = try encoder.encode(vote)

           let parameters: [AnyObject] = [jsonData as AnyObject, privateKey as AnyObject]


           let tx = contract.write(
               contractMethod,
               parameters: parameters,
               extraData: Data(),
               transactionOptions: transactionOptions)!

           let callRes = try tx.send(password: "web3swift")

           print(callRes) // Just a name of voting from smartContract
       }

}


fileprivate struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

// Интерфейс контракта. Описаны все методы, которые можно у него дернуть.
fileprivate let contractAbi: String =
"""
[{"inputs":[{"internalType":"string","name":"_name","type":"string"},{"internalType":"string","name":"_public_key","type":"string"},{"internalType":"string[]","name":"_voters","type":"string[]"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[],"name":"votedEvent","type":"event"},{"inputs":[],"name":"continue_voting","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"finish_voting","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"get_signs","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"get_voters_public_keys","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"get_votes","outputs":[{"internalType":"bytes[]","name":"","type":"bytes[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"public_encryption_key","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_secret_key","type":"string"}],"name":"publish_secret_key","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"secret_decryption_key","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"signs","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"start_voting","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"_vote","type":"bytes"},{"internalType":"string","name":"_sign","type":"string"}],"name":"vote","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"voters_public_keys","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"votes","outputs":[{"internalType":"bytes","name":"","type":"bytes"}],"stateMutability":"view","type":"function"}]
"""
