import math
import heapq  # used for the so colled "open list" that stores known nodes\

from finder import Finder, TIME_LIMIT, MAX_RUNS, DiagonalMovement 
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

def backtrace(node):

    path = [(node.x, node.y)]
    while node.parent:
        node = node.parent
        path.append((node.x, node.y))
    path.reverse()
    return path

class AStarFinder(Finder):
    
    def __init__(self, heuristic=manhattan, weight=1,
                 diagonal_movement=DiagonalMovement.never,
                 time_limit=TIME_LIMIT,
                 max_runs=MAX_RUNS):
        # weight: weight for the edges
        super(AStarFinder, self).__init__(
            heuristic=heuristic,
            weight=weight,
            diagonal_movement=diagonal_movement,
            time_limit=time_limit,
            max_runs=max_runs)
                


    def check_neighbors(self, start, end, matrix, open_list, backtrace_by=None):
        # pop node with minimum finishing distance
        node = heapq.nsmallest(1, open_list)[0]
        open_list.remove(node)
        node.closed = True

        if not backtrace_by and node == end:
            return backtrace(end)

        neighbors = self.find_neighbors(matrix, node)
        for neighbor in neighbors:
            if neighbor.closed:
                continue
            self.process_node(neighbor, node, end, open_list)
            
        return None

    def find_path(self, start, end, map):
        start.to_current = 0
        start.finish_distance = 0
        return super(AStarFinder, self).find_path(start, end, map)
