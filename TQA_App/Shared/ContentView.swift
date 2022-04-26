//
//  ContentView.swift
//  Shared
//
//  Created by Igor Iunash on 26.04.2022.
//

import SwiftUI
import web3
import BigInt


struct ContentView: View {


    public struct Vote: ABIFunction {
        public static let name = "vote"
        public let gasPrice: BigUInt? = "20000000000"
        public let gasLimit: BigUInt? = "6721975"
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        struct VoteTuple: ABITuple {
                func encode(to encoder: ABIFunctionEncoder) throws {
                    try encoder.encode(future_career_mark)
                    try encoder.encode(difficulty_mark)
                    try encoder.encode(comment)
                }

                static var types: [ABIType.Type] { [BigUInt.self, BigUInt.self, String.self] }

                var future_career_mark: BigUInt
                var difficulty_mark: BigUInt
                var comment: String

                init(future_career_mark: BigUInt, difficulty_mark: BigUInt, comment: String) {
                    self.future_career_mark = future_career_mark
                    self.difficulty_mark = difficulty_mark
                    self.comment = comment
                }

                init?(values: [ABIDecoder.DecodedValue]) throws {
                    self.future_career_mark = try values[0].decoded()
                    self.difficulty_mark = try values[1].decoded()
                    self.comment = try values[2].decoded()
                }

                var encodableValues: [ABIType] { [future_career_mark, difficulty_mark, comment] }
            }

        public let vote: VoteTuple

        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    vote: VoteTuple) {
            self.contract = contract
            self.from = from
            self.vote = vote
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(vote)
        }
    }

    static func setUpWeb3() async {
        let keyStorage = EthereumKeyLocalStorage()
        let account = try! EthereumAccount.importAccount(keyStorage: keyStorage,
                                                         privateKey: "0xfc98d3882a416dfed4b546e3852a8b7dcf63124dc9cce12adae08555181018db",
                                                         keystorePassword: "MY_PASSWORD")

        let clientUrl = URL(string: "http://127.0.0.1:8545")!
        let client = EthereumClient(url: clientUrl)

        let address = EthereumAddress("0xFAEDEe5B7f36538C0A503B64b7B0ccf2Eb320C38")
        let res = try! await client.eth_getBalance(address: address,
                                                   block: .Latest)


        print(res)
        print("HELLO")

        let function = Vote(contract: EthereumAddress("0xdD1510C3Da11FFf01b2c14A4B0d4F6c9058D0Ef4"),
                            from: EthereumAddress("0xfrom"),
                            vote: .init(future_career_mark: 10, difficulty_mark: 10, comment: "hello!"))
        let transaction = try! function.transaction()

        client.eth_sendRawTransaction(transaction, withAccount: account) { (error, txHash) in
            print("error: \(error.debugDescription)")
            print("TX Hash: \(String(describing: txHash))")
        }

    }

    init(){
        Task {
            await ContentView.setUpWeb3()
        }
    }

    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
