# SecureSend


## Introduction

SecureSend is a research project of the Institute for Applied Information Processing and 
Communications at the Graz University of Technology.

It is an iPhone application that provides the ability of sharing containers of data over 
the Internet in a secure and easy way. The primary focus was to keep it usable and secure 
without using a Public-Key Infrastructue (PKI) [1]. In order to avoid usability problems 
that normally occur when using a PKI for certificate verification and distribution, this 
application establishes a certain level of trust by introducing a Bluetooth and two-way 
key exchange. The containers are protected using the recipient's public-key out of the 
certificate, which is distributed either directly by Bluetooth or using the aforementioned 
two-channel exchange over Internet and GSM. The user can send the resulting encrypted 
container back to the owner of the certificate via email or share it using Dropbox [2]. 
Then the owner can decrypt it using his private key and access the user's sensitive data. 
The encryption and decryption is based on the CMS/SMIME standard and uses self-signed 
certificates.

## Screenshots
<img src="http://cstromberger.at/securesend/tut1@2x.png" />




## References
* [1] ... http://en.wikipedia.org/wiki/Public_key_infrastructure
* [2] ... http://www.dropbox.com
