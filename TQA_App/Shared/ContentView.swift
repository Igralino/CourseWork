//
//  ContentView.swift
//  Shared
//
//  Created by Igor Iunash on 26.04.2022.
//

import SwiftUI
import web3
import BigInt

extension String: Error {}

struct ContentView: View {

    @State private var difficulty = 5.0
    @State private var alert: Alert? = nil
    @State private var profit = 5.0
    @State private var comment = ""
    @State private var privateKey = ""
    @State private var web3Address = ""
    @State private var contractAddress = ""
    @State private var isEditing = false
    @State private var showingAlert = false

    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Данные аккаунта")) {
                    TextField("Ваш приватный ключ",
                              text: $privateKey)
                    TextField("Web3 адрес",
                              text: $web3Address)
                    TextField("Адрес контракта",
                              text: $contractAddress)
                }
                Section(header: Text("Оцени курс")) {
                    VStack(alignment: .leading) {
                        Text("Сложность курса: \(Int(difficulty))/10")
                            .fontWeight(.regular)
                        Slider(value: $difficulty,
                               in: 1...10,
                               step: 1) {
                            Text("Speed").background(.red)
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: { Text("10") }
                    }
                    VStack(alignment: .leading) {
                        Text("Полезность курса: \(Int(profit))/10")
                        Slider(value: $profit,
                               in: 1...10,
                               step: 1) {
                            Text("Speed").background(.red)
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: { Text("10") }
                    }
                }
                Section(header: Text("Комментарий")) {
                    TextField("Комментарий о курсе",
                              text: $comment)
                }
                Button("Отправить") {
                    Task {
                        do {
                            let tx = try await self.setUpWeb3()
                                alert = Alert(title: Text("Success"),
                                      message: Text(tx),
                                      dismissButton: .default(Text("Got it!")))

                            showingAlert = true
                        } catch {
                            alert = Alert(title: Text("Error"),
                                      message: Text(error.localizedDescription),
                                      dismissButton: .default(Text("Got it!")))
                            showingAlert = true

                        }
                    }
                }
            }
            .navigationTitle("СОП online")
            .alert(isPresented: $showingAlert) {
                alert!
            }
        }
    }

    public struct Vote: ABIFunction {
        public static let name = "vote"
        public let gasPrice: BigUInt? = "20000000000"
        public let gasLimit: BigUInt? = "6721975"
        public var contract: EthereumAddress
        public let from: EthereumAddress? = nil

        public let vote: Data

        public init(contract: EthereumAddress,
                    vote: Data) {
            self.contract = contract
            self.vote = vote
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(vote)
        }
    }

    func setUpWeb3() async throws -> String {
        let keyStorage = EthereumKeyLocalStorage()
        let account = try EthereumAccount.importAccount(keyStorage: keyStorage,
                                                        privateKey: privateKey.trimmingCharacters(in: .whitespaces),
                                                        keystorePassword: "MY_PASSWORD")

        guard let clientUrl = URL(string: web3Address) else {
            throw "WEB3 NOT URL"
        }
        let client = EthereumClient(url: clientUrl)

        var vote = Dictionary<String, String>()
        vote["difficulty"] = String(describing: Int(difficulty))
        vote["profit"] =  String(describing: Int(profit))
        vote["comment"] = comment

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(vote)

        let function = Vote(contract: EthereumAddress(contractAddress),
                            vote: jsonData)
        let transaction = try function.transaction()

        let tx = try await client.eth_sendRawTransaction(transaction, withAccount: account)
        return tx

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
