from brownie import accounts, EncryptedAnonimVoting


def main():
    account = accounts[0]
    _ = account.deploy(SimpleVoting, "Test voting")
