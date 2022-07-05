import json

from web3 import Web3
from web3.middleware import geth_poa_middleware

def get_contract(avax_net, contract_address, abi_file):
    web3 = Web3(Web3.HTTPProvider(avax_net))
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)
    with open(abi_file) as json_file:
        abi = json.load(json_file)
    contract_address_sum = web3.toChecksumAddress(contract_address)
    contract = web3.eth.contract(address=contract_address_sum, abi=abi)
    return contract

def read_buyers(contract):
    buyers = []
    index_buyer = 0
    while True:
        buyer_address = contract.functions.getBuyerAddress(index_buyer).call()
        if int(buyer_address, 0) == 0:
            break
        buyer_value = contract.functions.getBuyerValue(buyer_address).call()
        buyers.append((buyer_address, buyer_value))
        index_buyer += 1
    return buyers

if __name__ == "__main__":
    base_genesis_file = "genesis_base.json"
    output_custom_genesis = "custom_genesis.json"
    network_url = "https://api.avax-test.network/ext/bc/C/rpc"
    contract_address = "0x5e820f290c65ecaeb580daf1bb03acebf58ed3fc"
    abi_file = "abi.json"

    contract = get_contract(network_url, contract_address, abi_file)
    buyers = read_buyers(contract)
    with open(base_genesis_file) as json_file:
        base_genesis = json.load(json_file)
    
    new_alloc = {}
    for buyer_address, buyer_value in buyers:
        new_alloc[buyer_address[2:]] = {"balance" : hex(buyer_value)}

    base_genesis["alloc"] = new_alloc

    with open(output_custom_genesis, 'w') as f:
        json.dump(base_genesis, f)
    
