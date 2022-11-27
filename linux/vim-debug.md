
https://codeload.github.com/vim/vim/tar.gz/refs/tags/v9.0.0883

cd /home/c7u/vim-9.0.0883/
mkdir debug
./configure --prefixe=/home/c7u/vim-9.0.0883/debug
export CPPFLAGS=-DDEBUG
export CFLAGS="-g -O0"
make -j$(nproc)

rm -rf debug
make clean

检查有debug符合标
file src/vim |grep 'not stripped'
objdump --syms src/vim |grep debug
