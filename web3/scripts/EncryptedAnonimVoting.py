from brownie import accounts, EncryptedAnonimVoting
from brownie.network.state import Chain
from brownie import web3
import time
import os
from Crypto.PublicKey import RSA


def main():

    print("START!")
    account = accounts[0]
    key = RSA.generate(1024)
    private_key = str(key.export_key())
    public_key = str(key.publickey().export_key())
    print("KEYS:")
    print(f"\tprivate_key {private_key}")
    print(f"\tpublic_key {public_key}")
    now = int(time.time())
    voting = account.deploy(EncryptedAnonimVoting, "Test voting", public_key,
                            [accounts[0].address, accounts[1].address])
    voting.start_voting()
    voting.vote(b"random string1", {'from': accounts[0]})
    voting.vote(b"random string2", {'from': accounts[1]})
    voting.finish_voting()
    res = voting.tally_results()
    res = list(map(lambda x: x.decode('ascii'), res))
    print(res)


