import heapq  # used for the so colled "open list" that stores known nodes
import time  # for time limitation
import math


# max. amount of tries we iterate until we abort the search
MAX_RUNS = float('inf')
# max. time after we until we abort the search (in seconds)
TIME_LIMIT = float('inf')

class DiagonalMovement:
    always = 1
    never = 2

class Finder(object):
    def __init__(self, heuristic=None, weight=1,
                 diagonal_movement=DiagonalMovement.never,
                 weighted=True,
                 time_limit=TIME_LIMIT,
                 max_runs=MAX_RUNS):
# weight: weight for the edges
# weighted: weighted nodes
        self.time_limit = time_limit
        self.max_runs = max_runs
        self.weighted = weighted

        self.diagonal_movement = diagonal_movement
        self.weight = weight
        self.heuristic = heuristic

    def calc_cost(self, node_a, node_b):
        
        if node_b.x - node_a.x == 0 or node_b.y - node_a.y == 0:
            # direct neighbor
            dist = 1
        else:
            # not a direct neighbor - diagonal movement
            dist = math.sqrt(2)

        # weight for weighted algorithms
        if self.weighted:
            dist *= node_b.weight

        return node_a.to_current + dist

    def apply_heuristic(self, node_a, node_b, heuristic=None):

        if not heuristic:
            heuristic = self.heuristic
        return heuristic(
            abs(node_a.x - node_b.x),
            abs(node_a.y - node_b.y))

    def find_neighbors(self, map, node, diagonal_movement=None):
        
        if not diagonal_movement:
            diagonal_movement = self.diagonal_movement
        return map.neighbors(node, diagonal_movement=diagonal_movement)

    def keep_running(self):
        if self.runs >= self.max_runs:
            raise Exception('{} iterations without finding the destination'.format(self.max_runs))

        if time.time() - self.start_time >= self.time_limit:
            raise Exception('Aborting! Time limit exceeded! {} seconds, '.format(self.time_limit))

    def process_node(self, node, parent, end, open_list):
        # calculate cost from current node to the next neighbor
        cost = self.calc_cost(parent, node)

        if not node.opened or cost < node.to_current:
            node.to_current = cost
            node.to_goal = node.to_goal or \
                self.apply_heuristic(node, end) * self.weight
                
            node.finish_distance = node.to_current + node.to_goal
            node.parent = parent

            if not node.opened:
                heapq.heappush(open_list, node)
                node.opened = True
            else:
                open_list.remove(node)
                heapq.heappush(open_list, node)

    def find_path(self, start, end, map):
        self.start_time = time.time()
        self.runs = 0  # number of iterations
        start.opened = True

        open_list = [start]

        while len(open_list) > 0:
            self.runs += 1
            self.keep_running()

            path = self.check_neighbors(start, end, map, open_list)
            if path:
                return path, self.runs

        # failed to find path
        return [], self.runs