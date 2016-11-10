import os
import json
import unittest

from mock_kbase.clients.AbstractHandleClient import AbstractHandle

class TestHandleService(unittest.TestCase):
    def test_handle_service_up(self, port=None, token=None):
        if port is None:
            port = 7109
        if token is None:
            token = os.environ['KB_AUTH_TOKEN']

        url = "http://localhost:{}".format(port)
        print "Testing handle service at {}".format(url)

        hs = AbstractHandle(url, token=token)
        available_handles = hs.list_handles()
        self.assertTrue(available_handles is not None)
        print "Number of available handles: {}".format(len(available_handles))

        test_handle = hs.new_handle()
        hs.initialize_handle(test_handle)
        fetch_handle = hs.ids_to_handles([test_handle["id"]])[0]
        print "New handle: {}".format(json.dumps(test_handle,
                                                 sort_keys=True,
                                                 indent=4,
                                                 separators=(',',':')))
        print "Fetched by id handle: {}".format(json.dumps(fetch_handle,
                                                           sort_keys=True,
                                                           indent=4,
                                                           separators=(',',':')))
        self.assertTrue(test_handle["id"] == fetch_handle["id"], 
                        "ERROR: handle ids do not match".format(
                        test_handle, fetch_handle))
