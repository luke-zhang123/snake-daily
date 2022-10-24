#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os


def func1():
    """function 1

    :return:
    """
    print('func1')


class Node:
    """node class

    """

    def __init__(self):
        self.data = None

    def echo(self):
        print('Node.echo')


if __name__ == '__main__':
    print('start:'+os.path.basename(__file__))

    func1()

    node = Node()
    node.echo()
