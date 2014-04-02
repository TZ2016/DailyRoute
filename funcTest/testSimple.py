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


class TestAddUser(testLib.RestTestCase):
    """
    Test adding users
    """
    def assertResponse(self, respData, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        self.assertEqual(errCode, respData['errCode'])

    def testAdd(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData)

    def testAddMultiple(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)    

    def testAddEmptyUsername(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : '', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)

    def testAddWrongEmail(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'user0', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)    

    def testShortPassword(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'pass', 'password_confirmation' : 'pass'} )
        self.assertResponse(respData, errCode = -1)

    def inconsistentPassword(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password1'} )
        self.assertResponse(respData, errCode = -1)

class TestLogin(testLib.RestTestCase):
    """
    Test login
    """
    def assertResponse(self, respData, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        self.assertEqual(errCode, respData['errCode'])

    def testLoginTwice(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup",   method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        respData = self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.assertResponse(respData)   

    def testNoUser(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.assertResponse(respData, errCode = -1)

    def testWrongPassword(self):
        self.makeRequest('/main/reset', method="POST", data={})
        respData = self.makeRequest("/signup",   method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        respData = self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password1'} )
        self.assertResponse(respData, errCode = -1) 