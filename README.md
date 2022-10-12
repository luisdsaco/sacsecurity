# sacsecurity
Set of tools to increase cyber-security

In this repository you can find several tools to increase the security of linux systems.

The first one is a tool providing a vpn kill switch based on Network Manager.

# killswitch


killswitch is a tool that prevent you to continue sending packages over the network when the vpn fails.

There are several strategies to get this aim. The solution based on Network Manager is the easier one but, probably, the less secure too.

It has been tested in Ubuntu, Arch linux (with Network Manager installed) and Kali linux.

It is very simple and transparent, and it is easy to verify that the piece of code is secure itself. It is fully recommended to use it as a security measure if you work with a vpn over a not secure network.

# keyfinder

A key finder is a testing tool that searches for keys inside a text or a file and detects its presence. This version is a reduced one written in x86-64 assembler as an example of how to take advantage of microprocessors to improve security fast in real time.

This kind of tools are common in government agencies to spy communications searching for special words automaticly and firing notifications to the law enforcement bodies to make our societies safer.

keyfinder currently searches for the word "password" that is coded in text file with exactly 64 bits. The word can be stored directly in a register of a microprocessor of 64 bits. The comparison is done directly with only a single microprocessor instruction. This fact would let to implement an embedded system in a computer network analyzing the data flow with in the middle of a communication channel without affecting its performance. Of course, this is not very reusable, but the aim of the program is simply to show the benefits of implementing software directly on microprocessors instead of high level languages.

For software engineers this kind of tools can be useful to test if passwords are included in the code. This would be a bad programming practice if they want to write secure code.

A tool like keyfinder can be used as a fast automatic testing one in environments of continuous delivery.

This tool is implemented fully in assembler as an example of the direct use of microprocessors to provide fast processing for high performace environments, however, it is important to notice that assembled software is insecure by nature because it is very error prone and the programmer must manage directly a lot things that can drive to security breaches. For near production environments like those based on continuous delivery, a tool totally written in assembler should be used under your own risk.

This version manages the I/O through defined size memory blocks, the data processing is simple and it is done on the memory after gathering the data. That is the reason why it can be initally considered secure enough. You can try it without special security measures.
