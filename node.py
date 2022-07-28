# -*- coding: utf-8 -*-
class Node(object):
    # node saves X and Y and walkable.

    def __init__(self, x=0, y=0, walkable=True, weight=1):
        # Coordinates
        self.x = x
        self.y = y

        # Whether this node can be walked through.
        self.walkable = walkable

        # used for weighted algorithms
        self.weight = weight

        # values used in the finder
        self.cleanup()

    def __lt__(self, other):
    # comparing ndoe with final distance value
        return self.finish_distance < other.finish_distance

    def cleanup(self):
        # reset all values

        # cost from this node to the goal
        self.to_goal = 0.0

        # cost from the start node to this node
        self.to_current = 0.0

        # distance from start to goal
        self.finish_distance = 0.0

        self.opened = 0
        self.closed = False

        #backtracking
        self.parent = None