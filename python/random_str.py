#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 随机长度的随机字符

import random
import string

random = random.SystemRandom()

random_str = ''.join(random.choice(string.ascii_lowercase + string.digits + string.ascii_uppercase) for 
                     x in range(random.randrange(1, 10)))
print(random_str)
