# winutils
Windows binaries for Hadoop versions 

These are built directly from the same git commit used to create the official ASF releases; they are checked out
and built on a windows VM which is dedicated purely to testing Hadoop/YARN apps on Windows. It is not a day-to-day
used system so is isolated from driveby/email security attacks.


## Security: can you trust this release?

1. I am the Hadoop committer " stevel": I have nothing to gain by creating malicious versions of these binaries. If I wanted to run anything on your systems, I'd be able to add the code into Hadoop itself.
1. I'm signing the releases.
1. My keys are published on the ASF committer keylist [under my username](https://people.apache.org/keys/committer/stevel).
1. The latest GPG key (E7E4 26DF 6228 1B63 D679  6A81 950C C3E0 32B7 9CA2) actually lives on a yubikey for physical security; the signing takes place there.
1. The same pubikey key is used for 2FA to github, for uploading artifacts and making the release.

Someone malicious would need physical access to my office to sign artifacts under my name. If they could do that, they could commit malicious code into Hadoop itself, even signing those commits with the same GPG key. Though they'd need the pin number to unlock the key, which I have to type in whenever the laptop wakes up and I want to sign something. That'd take getting something malicious onto my machine, or sniffing the bluetooth packets from the keyboard to laptop. Were someone to get physical access to my machine, they could probably install a malicous version of `git`, one which modified code before the checkin. I don't actually my patches to verify that there's been no tampering, but we do tend to keep an eye on what our peers put in.

The other tactic would have been for a malicious yubikey to end up being delivered by Amazon to my house. I don't have any defences against anyone going to that level of effort.

*2017-12 Update* That key has been revoked, though it was never actually compromised. Lack of randomness in the prime number generator on the yubikey, hence
[an emergency cancel session](http://steveloughran.blogspot.co.uk/2017/10/roca-breaks-my-commit-process.html). Not set things up properly again.

Note: Artifacts prior to Hadoop 2.8.0-RC3 [were signed with a different key](https://pgp.mit.edu/pks/lookup?op=vindex&search=0xA92454F9174786B4; again, on the ASF key list.

## Build Process

A dedicated Windows Server 2012 VM is used for building and testing Hadoop stack artifacts. It is not used for *anything else*.

This uses a VS build setup from 2010; compiler and linker version: 16.00.30319.01 for x64


    >CL
    Microsoft (R) C/C++ Optimizing Compiler Version 16.00.30319.01 for x64
    Copyright (C) Microsoft Corporation.  All rights reserved.````

    >LINK /VERSION
    Microsoft (R) Incremental Linker Version 10.00.30319.01
    Copyright (C) Microsoft Corporation.  All rights reserved.



Maven 3.3.9 was used; signature checked to be that of Jason@maven.org. While my key list doesn't directly trust that signature, I do trust that of other signatorees:

https://pgp.mit.edu/pks/lookup?op=vindex&search=0xC7BF26D0BB617866


    C:\Work\hadoop-trunk>mvn --version
    Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-10T16:41:47+00:00)
    Maven home: C:\apps\maven\bin\..
    Java version: 1.8.0_74,   vendor: Oracle Corporation
    Java home: c:\java\jdk8\jre
    Default locale: en_GB, platform encoding: Cp1252
    OS name: "windows server 2012 r2", version: "6.3", arch: "amd64", family: "dos"
    The build is based on the instructions in Hadoop's BUILDING.TXT


Java 1.8:

```
>java -version
java version "1.8.0_121"
Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
```

## release process


### Windows VM

In `hadoop-trunk`

The version to build is checked out from the declared SHA1 checksum of the release/RC, hopefully moving to signed tags once signing becomes more common there.

The build was executed, relying on the fact that the `native-win` profile is automatic on Windows:


    mvn clean package -DskipTests -Pdist  -Dmaven.javadoc.skip=true 
    

This creates a distribution, with the native binaries under `hadoop-dist\target\hadoop-X.Y.Z\bin`

```
set VERSION=hadoop-2.8.3
cd winutils
mkdir %VERSION%
mkdir %VERSION%\bin
cd ..
copy trunk\hadoop-dist\target\%VERSION%\bin winutils\%VERSION%\bin
cd winutils
rm %VERSION%\bin\*.pdb
git add %VERSION%
git commit -m "Windows binaries for %VERSION%"
git push
```

Create a zip file containing the contents of the `winutils\%VERSION%`. This is done on the windows machine to avoid any risk of the windows line-ending files getting modified by git. This isn't committed to git, just copied over to the host VM via the mounted file share.

### Host machine: Sign everything

Pull down the newly added files from github, then sign the binary ones and push the .asc signatures back.




There isn't a way to sign multiple files in gpg2 on the command line, so it's either write a loop in bash or just edit the line and let path completion simplify your life. Here's the list of sign commands:


```

gpg --armor --detach-sign hadoop.dll
gpg --armor --detach-sign hadoop.exp
gpg --armor --detach-sign hadoop.lib
gpg --armor --detach-sign hadoop.pdb
gpg --armor --detach-sign hdfs.dll
gpg --armor --detach-sign hdfs.exp
gpg --armor --detach-sign hdfs.lib
gpg --armor --detach-sign hdfs.pdb 
gpg --armor --detach-sign libwinutils.lib 
gpg --armor --detach-sign winutils.exe
gpg --armor --detach-sign winutils.pdb

````

verify the existence of files, then 

```
git add *.asc
git status
git commit -S -m "sign Hadoop artifacts"
git push
```


Then go to the directory with the zip file and sign that file too

```
gpg --armor --detach-sign hadoop-2.8.0.zip 

```


### github, create the release

1. Go to the [github repository](https://github.com/steveloughran/winutils)
1. Verify the most recent commit is visible
1. [Create a new release](https://github.com/steveloughran/winutils/releases/new)
1. Tag the release with the hadoop version, include the commit checksum used to build off
1. Drop in the .zip and .zip.asc files as binary artifacts

