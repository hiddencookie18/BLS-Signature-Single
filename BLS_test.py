from __future__ import absolute_import


from typing import *
from py_ecc.typing import *
from py_ecc.bn128.bn128_curve import *
from py_ecc.bn128.bn128_pairing import *

import hashlib
import random
import sys

def rand_privkey():
    privkey = random.randint(2, curve_order - 1)
    return privkey

def generate_pubkey(priv) -> Point2D[Field]:

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

def hashToG1(hashval:int) -> Point2D[Field]:
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

        curvepoint = cast(Point2D[FQ], (FQ(x), FQ(y)))
        print("Hashing to G1 complete")
        print("G1 point is: "+ str(curvepoint))
       # print("The other point is ("+str(x)+" , "+str(field_modulus - y)+" )")

        return curvepoint

    else:

        hashval += 1
        return hashToG1(hashval)
def getHashG1(message) -> Point2D[Field]:
    hashfunc = hashlib.new('sha256')
    hashfunc.update((message).encode('utf-8'))

    hashval = int(hashfunc.hexdigest(), 16)
    print("Decimal value of hash: " + str(hashval))

    return hashToG1(hashval)

def Sign(privkey,message) -> Point2D[Field]:


    HM = getHashG1(message)
    print(is_on_curve(HM, b))

    return (multiply(HM, privkey))

privkey = rand_privkey()

pubkey =generate_pubkey(privkey)
print(pubkey)

message = "testmyhash"
signature = Sign(privkey, message)
HM = getHashG1(message)

print(is_on_curve(G2, b2))
print(is_on_curve(signature, b))
#print(FQ12.one())
#pair1 = pairing(G2,signature)
#pair2 = pairing(pubkey,HM)

#assert pair1 == pair2
#print(final_exponentiate(pairing(G2,signature) * pairing(pubkey,HM)) == FQ12.one())
print("*****SAMPLE SUCCESSFUL TEST CASE INPUTS****")
print("Signature: "+ str(signature))
print("Pubkey: "+ str(pubkey))
print("Message: "+message)


#print(pairing(G2, signature))
#print(pairing(pubkey, HM))
#print(pairing(G2,G1))



