"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib


        
class TestGenerateRoute(testLib.RestTestCase):
    """Test adding users"""
    def assertResponse(self, respData, errCode = 1, input = None, num = 0):
        """
        Check that the response data dictionary matches the expected values
        """
        print respData["errCode"]
        if input != None:
            self.assertDictEqual(input, respData["route"][num])
        self.assertEqual(errCode, respData["errCode"])

    def testNoConstrainOnePlaceError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)

    def testNoConstrainTwoPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)

    def testNoConstrainMultiPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData)


    def testNoConstrainOnePlace(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData, input={"lat": 38, "lng": -120}, num = 0)
        self.assertResponse(respData, input={"lat": 38, "lng": -120}, num = 1)


    def testNoConstrainMultiPlacesSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertResponse(respData, input={"lat": 38, "lng": -120}, num = 0)
        self.assertResponse(respData, input={"lat": 39, "lng": -121}, num = 3)

    def testNoConstrainOnePlaceSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertEqual(2, len(respData["route"]))

    def testNoConstrainMultiPlaces(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
        self.assertEqual(4, len(respData["route"]))

    def testDifferentTravelMethod(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "TRANSIT", 'locationList' : locationList} )
        self.assertResponse(respData)