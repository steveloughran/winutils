# winutils
Windows binaries for Hadoop versions 

These are built directly from the same git commit used to create the official ASF releases; they are checked out
and built on a windows VM which is dedicated purely to testing Hadoop/YARN apps on Windows. It is not a day-to-day
used system so is isolated from driveby/email security attacks.

Note that I am a Hadoop committer: I have nothing to gain by creating malicious versions of these binaries. If I wanted to run anything on your systems, I'd be able to add the code into Hadoop itself, or its build process.

I'm moving to `gpg -armor` signing of binaries; the GPG key used is on the [MIT key server](https://pgp.mit.edu/pks/lookup?op=vindex&search=0xA92454F9174786B4)

## release process


in `hadoop-trunk`

Check out the git commit ID voted on as the final release of the ASF artifacts.

```
mvn clean
mvn package -Pdist -Dmaven.javadoc.skip=true -DskipTests

```

This creates a distribution, with the native binaries under hadoop-dist\target


1. create dir winutils/$VERSION
1. copy bin\* to winutils/$VERSION
1. rm stuff you don't want
1. add the rest
1. GPG sign, add .ASC files.
1. commit
1. push
