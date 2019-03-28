%dw 2.0
import * from bat::BDD
import * from bat::Assertions

var context = bat::Mutable::HashMap()
var app_client_id = config.client_id
var app_client_secret = config.client_secret
var api_endpoint = config.url


fun header() = {
      "headers": {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "client_id":"$(app_client_id)",
            "client_secret":"$(app_client_secret)"
          }
    }
---
suite("Create Order Test") in [
  it must ('login') in [
    POST  `$(api_endpoint)/session` with {
        headers: header().headers,
        body: readUrl('classpath://data/login.json', 'application/json')
    } assert [
      $.response.status mustEqual 201 /*Ok*/
    ] execute [
       context.set('customerId', $.response.body.id)
   ]
  ],

  it must ('get shopping cart') in [
    GET `$(api_endpoint)/user/$(context.get('customerId'))/shopping_cart` with header()
    assert [
        $.response.status mustEqual 200
    ]
  ],

  it must ('list products') in [
    GET `$(api_endpoint)/products/search?maxResults=50&offset=0` with header()
    assert [
        $.response.status mustEqual 200
    ] execute [
        context.set('productId', $.response.body[1].id) // Save the First Product Id
    ]
  ],

  it must ('get product detail') in [
    GET `$(api_endpoint)/products/product/$(context.get('productId'))` with header()
    assert [
        $.response.status mustEqual 200
    ]
  ],
  it must ('add item to shopping cart') in [
    PUT `$(api_endpoint)/user/$(context.get('customerId'))/shopping_cart` with {
        headers: header().headers,
        body: readUrl('classpath://data/addToShoppingCart.json', 'application/json')
    } assert [
        $.response.status mustEqual 204
    ]
  ],
  it must ('confirm order') in [
    POST `$(api_endpoint)/user/$(context.get('customerId'))/shopping_cart/confirmation` with {
        headers: header().headers,
        body: readUrl('classpath://data/confirmation.json', 'application/json')
    } assert [
        $.response.status mustEqual 201
    ]
  ]
]