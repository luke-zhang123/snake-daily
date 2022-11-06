#!/usr/bin/env python
# -*- coding: utf-8 -*-

# source code from shadowsocksR-python
import hashlib
import logging
from ctypes import CDLL
from ctypes import c_char_p, c_int, c_long, byref, \
    create_string_buffer, c_void_p

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)-7s %(filename)s:%(lineno)s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

logging.info('script start')

libcrypto = None
loaded = False
buf_size = 2048


def load_openssl():
    global loaded, libcrypto, buf

    libcrypto = CDLL('C:\Windows\System32\libcrypto.dll')
    if libcrypto is None:
        raise Exception('libcrypto(OpenSSL) not found')

    libcrypto.EVP_get_cipherbyname.restype = c_void_p
    libcrypto.EVP_CIPHER_CTX_new.restype = c_void_p

    libcrypto.EVP_CipherInit_ex.argtypes = (c_void_p, c_void_p, c_char_p,
                                            c_char_p, c_char_p, c_int)

    libcrypto.EVP_CipherUpdate.argtypes = (c_void_p, c_void_p, c_void_p,
                                           c_char_p, c_int)

    if hasattr(libcrypto, "EVP_CIPHER_CTX_cleanup"):
        libcrypto.EVP_CIPHER_CTX_cleanup.argtypes = (c_void_p,)
    else:
        libcrypto.EVP_CIPHER_CTX_reset.argtypes = (c_void_p,)
    libcrypto.EVP_CIPHER_CTX_free.argtypes = (c_void_p,)

    libcrypto.RAND_bytes.restype = c_int
    libcrypto.RAND_bytes.argtypes = (c_void_p, c_int)

    if hasattr(libcrypto, 'OpenSSL_add_all_ciphers'):
        libcrypto.OpenSSL_add_all_ciphers()

    buf = create_string_buffer(buf_size)
    loaded = True


def load_cipher(cipher_name):
    func_name = 'EVP_' + cipher_name.replace('-', '_')
    cipher = getattr(libcrypto, func_name, None)
    if cipher:
        cipher.restype = c_void_p
        return cipher()
    return None


def EVP_BytesToKey(password, key_len, iv_len):
    # equivalent to OpenSSL's EVP_BytesToKey() with count 1
    # so that we make the same key and iv as nodejs version

    # openssl rc4 -k password -nosalt -e -nopad -p
    if hasattr(password, 'encode'):
        password = password.encode('utf-8')

    m = []
    i = 0
    while len(b''.join(m)) < (key_len + iv_len):
        md5 = hashlib.md5()
        data = password
        if i > 0:
            data = m[i - 1] + password
        md5.update(data)
        m.append(md5.digest())
        i += 1
    ms = b''.join(m)
    key = ms[:key_len]
    iv = ms[key_len:key_len + iv_len]
    logging.info('password [{}] kdf to key [{}]'.format(password, str2hex(key)))
    return key, iv


class OpenSSLCrypto(object):
    def __init__(self, cipher_name, key, iv, op):
        self._ctx = None
        if not loaded:
            load_openssl()
        cipher = libcrypto.EVP_get_cipherbyname(cipher_name)
        if not cipher:
            logging.info('cipher {} not found, try EVP_*'.format(cipher_name))
            cipher = load_cipher(cipher_name)
        else:
            logging.info('cipher {} found'.format(cipher_name))
        if not cipher:
            raise Exception('cipher %s not found in libcrypto' % cipher_name)
        key_ptr = c_char_p(key)
        iv_ptr = c_char_p(iv)
        self._ctx = libcrypto.EVP_CIPHER_CTX_new()
        if not self._ctx:
            raise Exception('can not create cipher context')
        r = libcrypto.EVP_CipherInit_ex(self._ctx, cipher, None,
                                        key_ptr, iv_ptr, c_int(op))
        if not r:
            self.clean()
            raise Exception('can not initialize cipher context')

    def update(self, data):
        global buf_size, buf
        cipher_out_len = c_long(0)
        l = len(data)
        if buf_size < l:
            buf_size = l * 2
            buf = create_string_buffer(buf_size)
        libcrypto.EVP_CipherUpdate(self._ctx, byref(buf),
                                   byref(cipher_out_len), c_char_p(data), l)
        # buf is copied to a str object when we access buf.raw
        return buf.raw[:cipher_out_len.value]

    def __del__(self):
        self.clean()

    def clean(self):
        if libcrypto is None:
            return
        if self._ctx:
            if hasattr(libcrypto, "EVP_CIPHER_CTX_cleanup"):
                libcrypto.EVP_CIPHER_CTX_cleanup(self._ctx)
            else:
                libcrypto.EVP_CIPHER_CTX_reset(self._ctx)
            libcrypto.EVP_CIPHER_CTX_free(self._ctx)


def str2hex(data_str):
    return ''.join(format(x, '02x') for x in bytearray(data_str))


if __name__ == '__main__':
    method = 'rc4'
    key_len = 16
    iv_len = 0

    logging.info('test...')
    password = 'weakPassWd123'
    key, iv_ = EVP_BytesToKey(password, key_len, iv_len)
    cipher = OpenSSLCrypto(method, key, iv=0, op=1)

    data_plain = 'openssl-rc4 data test'
    data_encrypt = '8534449f5e81237e9adb34db9c91157b2c3832d032'
    assert data_encrypt == str2hex(cipher.update(data_plain))
    del cipher

    logging.info('test...')
    password = 'p@ssw0rD'
    key, iv_ = EVP_BytesToKey(password, key_len, iv_len)
    cipher = OpenSSLCrypto(method, key, iv=0, op=1)

    data_plain = 'Message to be rc4 encrypted!!!'
    data_encrypt = '3604632e2f503ecb90c108acd3b0290275efff7c62581fe081224defb9dc'
    assert data_encrypt == str2hex(cipher.update(data_plain))
    del cipher

    logging.info('test...')
    password = 'p@ssw0rD'
    key, iv_ = EVP_BytesToKey(password, key_len, iv_len)
    cipher = OpenSSLCrypto(method, key, iv=0, op=1)

    data_plain1 = '01 Message to be encrypted!!!'
    data_encrypt1 = '4b5030102b44288a83cb08bad9b0390461aaf471735316e4902308efb9'
    data_plain2 = '02 Message to be encrypted!!!'
    data_encrypt2 = 'cdafcfb8eadf2aea6a2ea7d9d0e28da193cae5eea2e7a4697c25426cd8'
    data_plain3 = '03 Message to be encrypted!!!'
    data_encrypt3 = 'f5f87f702850cc1e9a8bd8b67cb8827cbf66647f6cdbf65e8bdeaf8678'

    assert data_encrypt1 == str2hex(cipher.update(data_plain1))
    assert data_encrypt2 == str2hex(cipher.update(data_plain2))
    assert data_encrypt3 == str2hex(cipher.update(data_plain3))




