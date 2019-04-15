from __future__ import absolute_import

from web3.providers.eth_tester import EthereumTesterProvider
from web3 import Web3, HTTPProvider
from typing import (
    cast,
)

from py_ecc.typing import *
from py_ecc.optimized_bn128.optimized_curve import *
from py_ecc.optimized_bn128.optimized_pairing import *
from py_ecc.optimized_bn128.optimized_field_elements import *


import hashlib
import random
import sys

def rand_privkey():
    privkey = random.randint(2, curve_order - 1)
    return privkey

def generate_pubkey(priv) -> Point3D[Field]:

   print("Private key: "+str(priv))
   return (multiply(G2, priv))

def is_QuadResidue(val:int) -> bool:
    # exponent is equal to (field_modulus - 1) / 2
    val = val % field_modulus
    exponent = 10944121435919637611123202872628637544348155578648911831344518947322613104291

    result = pow(val, exponent, field_modulus)
    if result == 1:
         return True
    else:
        return False

def checkHash(hashval:int) -> bool:
    hashval = hashval % field_modulus

    hashvalcubed = pow(hashval,3,field_modulus)
    result = (hashvalcubed + 3) % field_modulus

    return is_QuadResidue(result)

def hashToG1(hashval:int) -> Point3D[Field]:
    x = 0
    y = 0

    hashval = hashval % field_modulus
    print("Checking modular hash.... " + str(hashval))
    if checkHash(hashval):
       # exponent is equal to (field_modulus + 1) / 4
        exponent = 5472060717959818805561601436314318772174077789324455915672259473661306552146

        hashvalcubed = pow(hashval, 3, field_modulus)
        result = (hashvalcubed + 3) % field_modulus

        x = hashval
        y = pow(result, exponent, field_modulus)

        curvepoint = cast(Point3D[FQ], (FQ(x), FQ(y),FQ(1)))
        print("Hashing to G1 complete")
        print("G1 point is: "+ str(curvepoint))

        return curvepoint

    else:

        hashval += 1
        return hashToG1(hashval)
def getHashG1(message) -> Point3D[Field]:
    hashfunc = hashlib.new('sha256')
    hashfunc.update((message).encode('utf-8'))

    hashval = int(hashfunc.hexdigest(), 16)
    print("Decimal value of hash: " + str(hashval))

    return hashToG1(hashval)

def Sign(privkey,message) -> Point3D[Field]:


    HM = getHashG1(message)
    print(is_on_curve(HM, b))

    return (multiply(HM, privkey))

def Verify(pubkey,signature,Hash) -> bool:

   print("pair(G2,Signature):")
   print(pairing(G2, signature, final_exponentiate=False,))
   print("pair(Pubkey,HashofMessage):")
   print(pairing(pubkey, Hash, final_exponentiate=False, ))

   print("************************")
   result = final_exponentiate(pairing(G2, signature,final_exponentiate=False,) * pairing(neg(pubkey), HM,final_exponentiate=False,))
   return (result == FQ12.one())

privkey = rand_privkey()

pubkey =generate_pubkey(privkey)
print(pubkey)

signature = Sign(privkey, "testmyhash")
HM = getHashG1("testmyhash")

print(is_on_curve(G2, b2))
print(is_on_curve(signature, b))

print("************************")
print("G2:"+str(G2))
print("Signature: "+ str(signature))
print("Pubkey: "+ str(pubkey))
print("H(m):"+str(HM))

print("************************")

if Verify(pubkey,signature,HM):
    print("Verification successful")

else:
    print('Verification failed')




