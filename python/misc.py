#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# import a_module
# # 模块路径
# print(a_module.__file__)

# 查看str字符二进制
# print(' '.join(format(ord(x), 'b') for x in key))
# print(''.join(format(x, '02x') for x in bytearray(key)))

# 实例对象名称
self.cipher.__class__.__name__

# int转16进制，6表示一共6位，包括0x前缀，改成4可以显示一个字节255的16进制
print('{0:#0{1}x}'.format(123, 6))
print('{0:#0{1}x}'.format(0x23, 6))
print('{0:#0{1}x}'.format(0x23, 4))

# 16进制字符转二进制和int
print(ord('a'))
print('61'.decode('hex'))
print(ord('61'.decode('hex')))

# 以n个字符为一组，分割字符串line
[line[i:i+n] for i in range(0, len(line), n)]

