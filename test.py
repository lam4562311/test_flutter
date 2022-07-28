import math
import cv2
import numpy as np
import requests
from pynverse import inversefunc
import json
import sys

OFFSET = 268435456 # half of the earth circumference's in pixels at zoom level 21
RADIUS = OFFSET / math.pi

def get_pixel(x, y, x_center, y_center, zoom_level):
    """
    x, y - location in degrees
    long lat
    x_center, y_center - center of the map
    zoom_level - same value as in the google static maps URL
    x_ret, y_ret - position of x, y in pixels relative to the center of the bitmap
    """
    x_ret = (lng_to_x(x) - lng_to_x(x_center)) >> (21 - zoom_level)
    y_ret = (lat_to_y(y) - lat_to_y(y_center)) >> (21 - zoom_level)
    return x_ret, y_ret

def lng_to_x(x):
    return int(round(OFFSET + RADIUS * x * math.pi / 180))

def lat_to_y(y):
    return int(round(OFFSET - RADIUS * math.log((1 + math.sin(y * math.pi / 180)) / (1 - math.sin(y * math.pi / 180))) / 2))

def x_to_lng(x):
    return ((x - OFFSET) /RADIUS * 180  / math.pi)

def y_to_lat(y):
    return math.asin(1 - (2/(math.exp((OFFSET - y) * 2 / RADIUS) + 1))) * 180 / math.pi
    log = lambda x: OFFSET - RADIUS * math.log((1 + math.sin(x * math.pi / 180)) / (1 - math.sin(x * math.pi / 180))) / 2
    inv = inversefunc(log)
    print(inv(y))
    
    return None

def get_latlng(x_ret, y_ret, x_center, y_center, zoom_level):
    """
    x_ret : x coordinate
    y_ret : y coordinate
    x_center : lng of the center of the maps
    y_center : lat of the center of the maps
    """
    
    diff_x = x_ret << (21- zoom_level)
    diff_y = y_ret << (21- zoom_level)
    x = diff_x + lng_to_x(x_center)
    y = diff_y + lat_to_y(y_center)

    lng = x_to_lng(x)
    lat = y_to_lat(y)
    
    return lat, lng

sizeofMap_x, sizeofMap_y = 395, 457
print(get_pixel(114.001200,22.457265,114.000812285,22.4567357441, 19 ))
print (get_latlng(0,0,114.000812285,22.4567357441, 19))
print (get_latlng(int(344 - (395 + 1) / 2), int(11 - (457 + 1) /2),114.000812285,22.4567357441, 19))

# bottomN 22.456169335506456 longitudeE: 114.00083005428314
# leftN 22.45697990809377 longitudeE: 114.0002815425396
# leftN 22.456978668689764 longitudeE: 114.00028388947248
# rightN 22.45706945500401 longitudeE: 114.00134067982435
# upN 22.457302152759784 longitudeE: 114.00118477642536
#center 22.456728, 114.000813
#calc center 22.4567357441, 114.000811111/114.000812285

# x = requests.get('https://maps.googleapis.com/maps/api/staticmap?center=22.4567357441,%20114.000812285&zoom=19&size=395x457&maptype=roadmap&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0xffffff&style=element:labels%7Cvisibility:off&style=feature:administrative%7Cvisibility:off&style=feature:poi%7Cvisibility:off&style=feature:road%7Cvisibility:off&style=feature:transit%7Cvisibility:off&style=feature:water%7Celement:geometry%7Ccolor:0x000000&key=AIzaSyB-tnCNMsE5fPFMVZXgg9hAgFwX8Qlwz5k')
# print(x.content)
# img_str = x.content

out_file = open("img_str.json", "r")
b = json.load(out_file)
img_str = bytearray(b['img_str'], encoding="latin1")
out_file.close()

# print(get_pixel(114.00028388947248, 22.457302152759784,114.000812285, 22.4567357441,19))
# print(get_pixel(114.00134067982435, 22.456169335506456,114.000812285, 22.4567357441,19))


# print(bytearray(img_str))
nparr = np.frombuffer(img_str, dtype=np.uint8)
# nparr = np.array(img_str)
print(nparr)
img = cv2.imdecode(nparr, cv2.COLOR_RGB2BGR) # cv2.IMREAD_COLOR in OpenCV 3.1
height, width, channels = img.shape
for i in range(height):
    for j in range(width):
        # img[i, j] is the RGB pixel at position (i, j)
        # check if it's [0, 0, 0] and replace with [255, 255, 255] if so
        if img[i, j].sum() != 0:
            img[i, j] = [0, 0, 0]
        else:
            img[i, j] = [255, 255, 255]

img = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
height, width = img.shape
print(img)
# for i in range(height):
#     for j in range(width):
#         # img[i, j] is the RGB pixel at position (i, j)
#         # check if it's [0, 0, 0] and replace with [255, 255, 255] if so
#         if img[i, j] != 0:
#             img[i, j] = 1
# print(img)
np.savetxt('testout', img.astype(int)) 
cv2.imshow('map', img)
cv2.waitKey()
def main(arg1):
    path = arg1
    print(path, type(path))
    for item in path:
        print(item)
if __name__=="__main__":
    main(sys.argv[1])