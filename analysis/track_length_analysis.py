'''
Open source analysis for our data
'''
import os
from osgeo import gdal, ogr


def main(dir):
  fireshape = ogr.Open(dir+'fire.shp')
  demfile   = gdal.Open(dir+'bigElkDem.tif')



if __name__ == '__main__':
  print "Called analysis"

  main(r'/Users/jenningsanderson/gis/lab6/data/')
