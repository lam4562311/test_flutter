# -*- coding: utf-8 -*-
from .node import Node
import numpy as np

from finder import DiagonalMovement


def build_nodes(width, height, matrix=None):

    nodes = []
    for y in range(height):
        nodes.append([])
        for x in range(width):
            weight = int(matrix[y][x])
            walkable =  weight >= 1
            nodes[y].append(Node(x=x, y=y, walkable=walkable, weight=weight))
    return nodes


class Matrix(object):
    def __init__(self, width=0, height=0, map=None):
        """
        a grid represents the map (as 2d-list of nodes).
        """
        self.width = width
        self.height = height
        self.passable_left_right_border = False
        self.passable_up_down_border = False
        self.height = len(map)
        self.width  = len(map[0])
        self.nodes = build_nodes(self.width, self.height, map)

    def set_passable_left_right_border(self):
        self.passable_left_right_border = True

    def set_passable_up_down_border(self):
        self.passable_up_down_border = True

    def node(self, x, y):
        return self.nodes[y][x]

    def inside(self, x, y):
        self.width > x >= 0
        return self.width > x >= 0 and self.height > y >= 0

    def walkable(self, x, y):
        return self.inside(x, y) and self.nodes[y][x].walkable

    def neighbors(self, node, diagonal_movement=DiagonalMovement.never):
        # get all neighbors
        x = node.x
        y = node.y
        neighbors = []
        
        # up
        if y == 0 and self.passable_up_down_border:
            if self.walkable(x, self.height - 1):
                neighbors.append(self.nodes[self.height - 1][x])
        else:
            if self.walkable(x, y - 1):
                neighbors.append(self.nodes[y - 1][x])
        # right
        if x == self.width - 1 and self.passable_left_right_border:
            if self.walkable(0, y):
                neighbors.append(self.nodes[y][0])
        else:
            if self.walkable(x + 1, y):
                neighbors.append(self.nodes[y][x + 1])
        # down
        if y == self.height - 1 and self.passable_up_down_border:
            if self.walkable(x, 0):
                neighbors.append(self.nodes[0][x])
        else:
            if self.walkable(x, y + 1):
                neighbors.append(self.nodes[y + 1][x])
        # left
        if x == 0 and self.passable_left_right_border:
            if self.walkable(self.width - 1, y):
                neighbors.append(self.nodes[y][self.width - 1])
        else:
            if self.walkable(x - 1, y):
                neighbors.append(self.nodes[y][x - 1])
                
        if diagonal_movement == DiagonalMovement.never:
            return neighbors
        # ul
        if self.walkable(x - 1, y - 1):
            neighbors.append(self.nodes[y - 1][x - 1])

        # ur
        if self.walkable(x + 1, y - 1):
            neighbors.append(self.nodes[y - 1][x + 1])

        # dr
        if self.walkable(x + 1, y + 1):
            neighbors.append(self.nodes[y + 1][x + 1])

        # dl
        if self.walkable(x - 1, y + 1):
            neighbors.append(self.nodes[y + 1][x - 1])

        return neighbors

    def cleanup(self):
        for y_nodes in self.nodes:
            for node in y_nodes:
                node.cleanup()
