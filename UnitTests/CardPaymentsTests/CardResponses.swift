enum CardResponses: String {
    case confirmPaymentSourceJson = """
        {
            "id": "testOrderId",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            }
        }
        """

    case confirmPaymentSourceJsonWith3DS = """
        {
            "id": "testOrderId",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            },
            "links": [
                {
                    "rel": "payer-action",
                    "href": "https://fakeURL?PayerID=98765"
                }
            ]
        }
        """
    
    case confirmPaymentSourceJsonInvalid3DSURL = """
        {
            "id": "testOrderId",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            },
            "links": [
                {
                    "rel": "payer-action",
                    "href": ""
                }
            ]
        }
        """

    case successfullGetOrderJson = """
        {
            "id": "testOrderId",
            "status": "CREATED",
            "intent": "CAPTURE",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT",
                    "authentication_result": {
                        "liability_shift": "POSSIBLE",
                            "three_d_secure": {
                                "enrollment_status": "Y",
                                "authentication_status": "Y"
                            }
                    }
                }
            },
            "links": [
                {
                    "rel": "payer-action",
                    "href": "https://fakeURL?PayerID=98765"
                }
            ]
        }
        """
}
