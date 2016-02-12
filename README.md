# winutils
Windows binaries for Hadoop versions (as taken from HDP releases)

## release process


in hadoop-trunk


```
mvn clean
mvn package -Pdist -Dmaven.javadoc.skip=true -DskipTests

```

This creates a distribution, with the native binaries under hadoop-dist\target

create dir winutils/$VERSION

copy bin\* to winutils/$VERSION

rm stuff you don't want

add the rest
commit
push
```

```