from brownie import accounts, network, config, EncryptedAnonimVoting
from brownie.network.state import Chain
from brownie import web3
import time
import os
from Crypto.PublicKey import RSA


def get_account():
    if network.show_active() == "localnet":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy(account):
    key = RSA.generate(1024)
    private_key = str(key.export_key())
    public_key = str(key.publickey().export_key())
    print("KEYS:")
    print(f"\t{private_key}")
    print(f"\t{public_key}")

    voting = account.deploy(EncryptedAnonimVoting, "Test voting", public_key,
                            ["Key1", "Key2"], publish_source=True)
    return voting


def main():
    account = get_account()
    print("Current developer account:", account)
    print("Balance:", account.balance()/(10**18))

    voting = deploy(account)

    # voting.start_voting()
    # voting.vote(b"random string1", "random_string", {'from': accounts[0]})
    # voting.vote(b"random string2", "second_random_string", {'from': accounts[1]})
    # voting.finish_voting()
    #
    # votes = voting.return_votes()
    # signs = voting.return_signs()
    #
    # votes = list(map(lambda x: x.decode('ascii'), votes))
    #
    # print(votes)
    # print(signs)