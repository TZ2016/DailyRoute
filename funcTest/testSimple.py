"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib


        
class TestGenerateRoute(testLib.RestTestCase):
    """Test adding users"""
    def assertResponse(self, respData, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        self.assertDictEqual(errCode, respData[errCode])

    def testNoConstrainOnePlace(self):
        locationList = []
        locationList.append({"searchtext": random, "geocode": {"lat": 38, "lng": -120}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)

    def testNoConstrainTwoPlaces(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)

    def testNoConstrainMultiPlaces(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 35, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 37, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -118}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)

    def testWithConstrainDurationPossible(self):
        locationList = []
        locationList.append({"searchtext": random, "geocode": {"lat": 38, "lng": -120}, "minduration": 15, "maxduration": 30})
        locationList.append({"searchtext": random, "geocode": {"lat": 38, "lng": -110}, "minduration": 15, "maxduration": 30})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)


    def testWithConstrainDurationImpossible(self):
        locationList = []
        locationList.append({"searchtext": random, "geocode": {"lat": 38, "lng": -120}, "minduration": 30, "maxduration": 15})
        locationList.append({"searchtext": random, "geocode": {"lat": 38, "lng": -110}, "minduration": 15, "maxduration": 30})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData, errCode = -2)