//
//  GooglePlaceDetailsRequestTests.swift
//  GooglePlacesAutocompleteExample
//
//  Created by Howard Wilson on 25/03/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import Foundation
import XCTest
import GooglePlacesAutocomplete

class GooglePlaceDetailsRequestTests: XCTestCase {
  let json: [String : AnyObject] = [
    "html_attributions" : [],
    "result" : [
      "formatted_address" : "48 Pirrama Road, Pyrmont NSW, Australia",
      "formatted_phone_number" : "(02) 9374 4000",
      "geometry" : [
        "location" : [
          "lat" : -33.8669710,
          "lng" : 151.1958750
        ]
      ],
      "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png",
      "id" : "4f89212bf76dde31f092cfc14d7506555d85b5c7"
      // ...
    ],
    "status" : "OK"
  ]

  func testSuccessfulDetailsRequest() {
    let place = Place(prediction: ["place_id": "691b237b0322f28988f3ce03e321ff72a12167fd", "description": "Paris, France"], apiKey: "APIKEY")
    let expectation = self.expectationWithDescription("Should return details")

    OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
      return request.URL.absoluteString == "https://maps.googleapis.com/maps/api/place/details/json?key=APIKEY&placeid=\(place.id)"
      }, withStubResponse: { (request: NSURLRequest!) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(JSONObject: self.json, statusCode: 200, headers: nil)
    })

    place.getDetails { (details: [String: AnyObject]) in
      if let result = details["result"] as? [String: AnyObject] {
        if let geometry = result["geometry"] as? [String: AnyObject] {
          if let location = geometry["location"] as? [String: AnyObject] {
            XCTAssertEqual(location["lat"] as Double, -33.8669710)
            XCTAssertEqual(location["lng"] as Double, 151.1958750)

            expectation.fulfill()
          }
        }
      }
    }

    self.waitForExpectationsWithTimeout(2.0, handler: nil)
  }
}
