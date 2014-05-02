"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib

def dct_new_user(email='test@dailyroute.com', pw='testpassword', pwcf='testpassword'):
    user = { 'email': email, 'password': pw, 'password_confirmation': pwcf}
    return {'user': user}

def dct_test_user():
    return { 'email': 'test@dailyroute.com', 'password': 'testpassword'}

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
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)

    def testNoConstrainTwoPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)

    def testNoConstrainMultiPlacesError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -121}})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
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
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "TRANSIT", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)


    def testWithConstriantOnePlaceError(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)


    def testWithConstrantOnePlaceSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)


    def testWithConstrantMultiPlaceSize(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -120}, "arriveafter": "11:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)


    def testWithConstrantMultiPlace(self):
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        locationList.append({"searchtext": "random", "geocode": {"lat": 39, "lng": -120}, "arriveafter": "11:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)






class TestSaveRoute(testLib.RestTestCase):

    def assertResponse(self, respData, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        self.assertEqual(errCode, respData['errCode'])

    def testSavedRoutes(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        respData = self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        self.assertResponse(respData)

    def testSavedRoutesSize(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        respData=self.makeRequest('/tests/routes_of_user', method="POST", data={'session' : dct_test_user()})
        self.assertEqual(0,len(respData['routes']))

    def testRemoveRoutes(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        respData=self.makeRequest('/tests/remove_all_routes_of', method="POST", data={'session' : dct_test_user()})
        self.assertResponse(respData)

    def testAfterRemoveRoutes(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        respData=self.makeRequest('/tests/routes_of_user', method="POST", data={'session' : dct_test_user()})
        self.assertResponse(respData)


    def testRemoveRoutesSize(self):
        self.makeRequest('/tests/resetAll', method="GET")
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        locationList = []
        locationList.append({"searchtext": "random", "geocode": {"lat": 38, "lng": -120}, "arriveafter": "10:00pm"})
        self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.makeRequest("/signin_post", method="POST", data = { 'email' : 'test@test.com', 'password' : 'password'} )
        self.makeRequest("/tests/add_route_to", method="POST", data = { 'route' : {'mode' : "DRIVING", 'name' : 'testroute'}, 
            'session' : dct_test_user()} )
        respData=self.makeRequest('/tests/routes_of_user', method="POST", data={'session' : dct_test_user()})
        self.assertEqual(0,len(respData['routes']))




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
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.assertResponse(respData)

    def testAddMultiple(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user() )
        self.assertResponse(respData, errCode = -1)    

    def testAddBlankUsername(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user(" ") )
        self.assertResponse(respData, errCode = -1)

    def testAddWrongEmail(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user("wrongemail") )
        self.assertResponse(respData, errCode = -1)    

    def testShortPassword(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user(pw="short") )
        self.assertResponse(respData, errCode = -1)

    def inconsistentPassword(self):
        self.makeRequest('/tests/resetAll', method="GET")
        respData = self.makeRequest("/signup_post", method="POST", data = dct_new_user(pwcf="different") )
        self.assertResponse(respData, errCode = -1)
