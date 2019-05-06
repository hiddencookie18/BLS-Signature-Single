pragma solidity ^0.4.14;

/* 
-Pairing operation is based on the code from "https://github.com/Project-Arda/bgls-on-evm" 
and curve operations are based on the code from "https://gist.github.com/BjornvdLaan/ca6dd4e3993e1ef392f363ec27fe74c4"

-Test cases that provide inputs of (signature, pubkey, message) can be generated using BLS_test.py

** Be careful in inputs of type G2Point! 
*** G2 points in this code are represented in reverse order of BLS_test.py
** For example; G2 point of [1111,2222,3333,4444] in BLS_test.py is represented as a G2 point like G2Point([2222,1111],[4444,3333] in this code
*/

library BLSSignature {
    struct G1Point {
        uint X;
        uint Y;
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    function G1() internal returns (G1Point) {
        return G1Point(1, 2);
    }

    function G2() internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    
       function test() internal returns (bool){
        bytes memory message = "testmyhash";
        
        
        G1Point memory signature = G1Point(12549556076515499309678673192404568282590030638915141025699763738995528297829, 10069141092585373492406241879436116983969003105301475420698830666872304665050);

        G2Point memory pubkey = G2Point(
            [10030244269781260283755623675552146909292962154180924014297942687162625408588, 13047368847798712176526920720814293572358305691215147789002472547302297622266],
            [3914694405438683764367653986078009943559570116874831532144098124750523839045, 677545526153648417644390756566867473077828717458641435542112485698510171785]
        );

        return BLSVerify(signature,pubkey,message);
    }
    

    function BLSVerify(G1Point signature,G2Point pubkey,bytes message) internal returns (bool) {

        G1Point memory hash = hashToG1(message);
   
        return pairing(signature,G2(),hash,pubkey);
    }
    
      function pairing(G1Point a, G2Point x, G1Point b, G2Point y) internal returns (bool) {
         uint256 field_modulus = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    uint256[12] memory input = [a.X, a.Y, x.X[0], x.X[1], x.Y[0], x.Y[1], b.X, field_modulus - b.Y, y.X[0], y.X[1], y.Y[0], y.Y[1]];
    uint[1] memory result;
  
      bool check;

        assembly {
            check := call(sub(gas, 2000), 8, 0, input,  0x180, result, 0x20)

            switch check case 0 {invalid}
        }
        require(check);
    
    return result[0]==1;
  }
    
      function modPow(uint256 base, uint256 exponent, uint256 modulus) internal returns (uint256) {
    uint256[6] memory input = [32,32,32,base,exponent,modulus];
    uint256[1] memory result;
            bool success;

    assembly {
      success :=call(sub(gas, 2000), 5, 0, input, 0xc0, result, 0x20) {
       
      }
    }
    return result[0];
  }


  function hashToG1(bytes message) internal returns (G1Point) {
           uint256 field_modulus = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

              uint256 hashval = uint256(sha256(message));
              hashval = hashval % 21888242871839275222246405745257275088696311157297823662689037894645226208583;
      uint256 hashtest = hashval;

    while (true) {
      uint256 result = (modPow(hashtest,3,field_modulus) + 3);
      if (modPow(result, 10944121435919637611123202872628637544348155578648911831344518947322613104291, field_modulus) == 1) {
        uint256 py = modPow(result, 5472060717959818805561601436314318772174077789324455915672259473661306552146, field_modulus);
          return G1Point(hashtest,py);
        
      } else {
        hashtest++;
      }
    }
  }
 
    function negate(G1Point p) internal returns (G1Point) {
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

      function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            switch success case 0 {invalid}
        }
        require(success);
    }
    function multiply(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            switch success case 0 {invalid}
        }
        require(success);
    }
}
