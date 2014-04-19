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
        self.makeRequest('/tests/resetAll', method="GET")
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)

    def testNoConstrainTwoPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)

    def testNoConstrainMultiPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)


    # def testNoConstrainOnePlaceSize(self):
    #     locationList = []
    #     locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
    #     respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
    #     self.assertEqual(2, len(respData["route"][0]))

    # def testNoConstrainMultiPlaces(self):
    #     locationList = []
    #     locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
    #     locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
    #     locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
    #     locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
    #     respData = self.makeRequest("/main/master", method="POST", data = { 'travelMethod' : "DRIVING", 'locationList' : locationList} )
    #     self.assertEqual(4, len(respData["route"][0]))

    def testDifferentTravelMethod(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "TRANSIT", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)


    def testWithConstriantOnePlaceError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)


    def testWithConstrantOnePlaceSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)


    def testWithConstrantMultiPlaceSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -120}, "arriveafter": "11:00pm"})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)


    def testWithConstrantMultiPlace(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -120}, "arriveafter": "11:00pm"})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
        self.assertResponse(respData)






class TestSaveRoute(testLib.RestTestCase):

    def assertResponse(self, respData, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        self.assertEqual(errCode, respData['errCode'])

    def testSavedRoutes(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.makeRequest("/signin", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : {'email' : 'test@test.com', 'password' : 'password'}} )
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
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData)

    def testAddMultiple(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)    

    def testAddEmptyUsername(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : '', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)

    def testAddWrongEmail(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'user0', 'password' : 'password', 'password_confirmation' : 'password'} )
        self.assertResponse(respData, errCode = -1)    

    def testShortPassword(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'pass', 'password_confirmation' : 'pass'} )
        self.assertResponse(respData, errCode = -1)

    def inconsistentPassword(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password', 'password_confirmation' : 'password1'} )
        self.assertResponse(respData, errCode = -1)
