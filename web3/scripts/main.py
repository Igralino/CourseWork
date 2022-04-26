from brownie import accounts, config, network, TQA_Voting

# LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "mainnet-fork"]
#
#
# def get_account():
#     if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
#         return accounts[0]
#     if network.show_active() in config["networks"]:
#         account = accounts.add(config["wallets"]["from_key"])
#         return account
#     return None


def main():
    account = accounts[0]
    print(f"account = {account}")
    voting = account.deploy(TQA_Voting, "Test voting")

    print(f"Voting name = {voting.name()}")
    voting.vote((5, 4, "good"))
    # erc20 = EasyToken.deploy({"from": account})


main()
