pragma solidity ^0.4.14;

/* 
-Pairing and other elliptic operations are based on the code from "https://gist.github.com/BjornvdLaan/ca6dd4e3993e1ef392f363ec27fe74c4"

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

    function BLSVerify(G1Point signature,G2Point pubkey,bytes message) internal returns (bool) {
        G1Point[] memory G1pts = new G1Point[](2);
        G2Point[] memory G2pts = new G2Point[](2);

        G1Point memory hash = hashToG1(message);
        
        G1pts[0] = negate(signature);
        G1pts[1]= hash;
        G2pts[0]=G2();
        G2pts[1]= pubkey;
        

        return pairing(G1pts,G2pts);
    }


  
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](6);

        for (uint i = 0; i < elements; i++)
        {
            input[0] = p1[i].X;
            input[1] = p1[i].Y;
            input[2] = p2[i].X[0];
            input[3] = p2[i].X[1];
            input[4] = p2[i].Y[0];
            input[5] = p2[i].Y[1];
        }

        uint[1] memory out;
        bool check;

        assembly {
            check := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)

            switch check case 0 {invalid}
        }
        require(check);
        return out[0] != 0;
    }

    function hashToG1(bytes message) internal returns (G1Point) {
        uint256 h = uint256(keccak256(message));
        return multiply(G1(), h);
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