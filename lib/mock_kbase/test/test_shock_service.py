import os
import json
import datetime
import unittest

from mock_kbase.clients.shock import Client

class TestHandleService(unittest.TestCase):
    def setUp(self):
        self.port = 7044
        self.token = os.environ['KB_AUTH_TOKEN']

    def test_shock_service_up(self):
        url = "http://localhost:{}".format(self.port)
        print "Testing shock service at {}".format(url)

        sc = Client(url, token=self.token)
        nodes = sc._get_node_data('')
        self.assertTrue(nodes is not None)
        print "Number of available shock nodes: {}".format(len(nodes))
        print nodes

        print "Generating random 10MB file for testing upload to shock"
        filename = 'test_shock_upload.bin'
        start = datetime.datetime.utcnow()
        with open(filename, 'wb') as f:
            f.write(os.urandom(10 * 2**20))
        end = datetime.datetime.utcnow()
        print "File generated in: {}".format(end - start)

        node_info = sc.upload(data=open(filename, 'rb'), file_name=filename)
        data = sc.get_node(node_info["id"])
        self.assertTrue(data["file"]["checksum"] == node_info["file"]["checksum"], 
                        "ERROR: checksums don't match! {}\n{}".format(
                        data["file"]["checksum"], node_info["file"]["checksum"]))