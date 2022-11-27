openjdk
https://adoptium.net/temurin/releases/
https://jdk.java.net/archive/

shasum -a 256 openjdk-xxx.tar.gz
  tar -xf openjdk-xxx.tar.gz -C $HOME/OpenJDK  # $HOME/OpenJDK/jdk-17.0.1.jdk/Contents/Home
```vi .zshrc
export JAVA_HOME=$HOME/jdk-17.0.1.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
```

