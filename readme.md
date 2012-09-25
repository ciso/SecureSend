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


## Overview
SecureSend allows you to store files in secure containers on your iPhone and share these 
containers with other persons via eMail and Dropbox. 
The containers are protected from unauthorised access by using state-of-the-art 
encryption. Before sharing a container with another recipient the person's certificate 
can be retrieved via bluetooth or eMail.

Files from other applications can simply be added to a container by opening them in 
SecureSend (e.g. from your eMail client). We highly recommended to set a passcode for 
your iPhone. Only then, the files within SecureSend are adequately protected by using 
the iPhones data protection system.


### Features:
- Securely store files in SecureSend
- Securely share data with other persons
- Exchange certificates via Bluetooth or Email


## Screenshots
<img src="http://cstromberger.at/securesend/tut1@2x.png" />
<img src="http://cstromberger.at/securesend/tut2@2x.png" />

<img src="http://cstromberger.at/securesend/tut3@2x.png" />
<img src="http://cstromberger.at/securesend/tut4@2x.png" />


## Technical details
SecureSend uses CMS/SMIME to create encrypted containers. In order to encrypt a container 
for a recipient, the X509 certificate of this person is required. SecureSend uses 
self-signed certificates that can be exchanged via eMail or Bluetooth. When exchanging 
certificates via eMail, a checksum (SHA1 hash value) is also sent via SMS that can be 
compared with the checksum of the received certificate. Due to the use of self-signed 
certificates (instead relying on a PKI), these two channels provide a higher level of 
trust than by using only an email for the exchanging certificates. For detailed 
information (including the source code of SecureSend) please visit the developer's 
website.




## References
* [1] ... http://en.wikipedia.org/wiki/Public_key_infrastructure
* [2] ... http://www.dropbox.com
