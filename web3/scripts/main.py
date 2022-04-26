from brownie import accounts, TQA_Voting


def main():
    account = accounts[0]
    _ = account.deploy(TQA_Voting, "Test voting")
