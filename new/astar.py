import math
import heapq  # used for the so colled "open list" that stores known nodes
import time  # for time limitation

# max. amount of tries we iterate until we abort the search
MAX_RUNS = float('inf')
# max. time after we until we abort the search (in seconds)
TIME_LIMIT = float('inf')

class DiagonalMovement:
    always = 1
    never = 2

def euclidean(dx, dy):
# euclidean distance
    return math.sqrt(dx * dx + dy * dy)

def chebyshev(dx, dy):
# Chebyshev distance
    return max(dx, dy)

def manhattan(dx, dy):
# manhattan distance
    return dx + dy

def octile(dx, dy):
# octile distance
    f = math.sqrt(2) - 1
    if dx < dy:
        return f * dx + dy
    else:
        return f * dy + dx

class AStarFinder(object):
    def __init__(self, heuristic=manhattan, weight=1,
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

    def apply_heuristic(self, node_a, node_b):
        return self.heuristic(
            abs(node_a.x - node_b.x),
            abs(node_a.y - node_b.y))

    def find_neighbors(self, map, node):
        return map.neighbors(node, diagonal_movement=self.diagonal_movement)

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
        start.to_current = 0
        start.finish_distance = 0
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
    
    def backtrace(self, node):
        path = [(node.x, node.y)]
        while node.parent:
            node = node.parent
            path.append((node.x, node.y))
        path.reverse()
        return path
    
    def check_neighbors(self, start, end, matrix, open_list):
        # pop node with minimum finishing distance
        node = heapq.nsmallest(1, open_list)[0]
        open_list.remove(node)
        node.closed = True
        if node == end:
            return self.backtrace(end)

        neighbors = self.find_neighbors(matrix, node)
        for neighbor in neighbors:
            if neighbor.closed:
                continue
            self.process_node(neighbor, node, end, open_list)
            
        return None
