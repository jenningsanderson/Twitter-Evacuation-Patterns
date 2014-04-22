# -*- coding: utf-8 -*-
"""##################################
Created on Sat Apr 19 11:06:13 2014
###################################"""

import arcpy
from arcpy import env
env.workspace = r"D:\Project"
env.overwriteOutput = 1
import csv

users = []


with open('ImportToArcmap.csv' , 'rb') as csvfile:
    reader = csv.reader(csvfile)
    reader.next()
    for i in range(0,1065):
        this_user = {}
        before_row = reader.next()
        during_row = reader.next()
        after_row = reader.next()        
        
        this_user['Name'] = before_row[0]

        before_point = arcpy.Point() 
        before_point.Y = float(before_row[2])
        before_point.X = float(before_row[3])
    
        this_user['Before'] = (before_point)  
        
        during_point = arcpy.Point() 
        during_point.Y = float(during_row[2])
        during_point.X = float(during_row[3])
        
        this_user['During'] = (during_point)   

        after_point = arcpy.Point() 
        after_point.Y = float(after_row[2])
        after_point.X = float(after_row[3])
    
        this_user['After'] = (after_point)   

        users.append(this_user)    


sr = arcpy.SpatialReference(4326)

arcpy.CreateFeatureclass_management(env.workspace, 'beforePoints.shp','POINT', spatial_reference = sr )
arcpy.CreateFeatureclass_management(env.workspace, 'duringPoints.shp','POINT', spatial_reference = sr)
arcpy.CreateFeatureclass_management(env.workspace, 'afterPoints.shp','POINT', spatial_reference = sr)

arcpy.AddField_management('beforePoints.shp', 'Name', 'STRING')
arcpy.AddField_management('duringPoints.shp', 'Name', 'STRING')
arcpy.AddField_management('afterPoints.shp', 'Name', 'STRING')  

beforeCur = arcpy.InsertCursor('beforePoints.shp')
duringCur = arcpy.InsertCursor('duringPoints.shp')
afterCur = arcpy.InsertCursor('afterPoints.shp')    
    
for user in users:
    beforeRow = beforeCur.newRow()
    beforeRow.Name = user['Name']
    beforeRow.shape = user['Before']
    beforeCur.insertRow(beforeRow)     

    duringRow = duringCur.newRow()
    duringRow.Name = user['Name']
    duringRow.shape = user['During']
    duringCur.insertRow(duringRow)
    
    afterRow = afterCur.newRow()
    afterRow.Name = user['Name']
    afterRow.shape = user['After']
    afterCur.insertRow(afterRow)

del beforeCur, duringCur, afterCur, beforeRow, duringRow, afterRow


zones = 'NYC_EvacZones.shp'     

arcpy.Clip_analysis('beforePoints.shp', zones, 'clipped_before.shp')
arcpy.Clip_analysis('duringPoints.shp', zones, 'clipped_during.shp')
arcpy.Clip_analysis('afterPoints.shp', zones, 'clipped_after.shp')

print 'done'

SerBefore = arcpy.SearchCursor('clipped_before.shp')
SerDuring = arcpy.SearchCursor('clipped_during.shp')
SerAfter = arcpy.SearchCursor('clipped_after.shp')

BeforeList = []
DuringList = []
AfterList = []

for people in SerBefore:
    BeforeList.append(people.Name)
del people, SerBefore

for people in SerDuring:
    DuringList.append(people.Name)
del people, SerDuring

for people in SerAfter:
    AfterList.append(people.Name)
del people, SerAfter

#Sheltered-in-place
list(set(BeforeList) & set(DuringList) & set(AfterList))

#Evacuation
list(set(BeforeList) & set(AfterList) - set(DuringList))

#Did not return home 
list(set(BeforeList)- set(DuringList)- set(AfterList))


