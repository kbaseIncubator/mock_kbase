import os
import json
import datetime
import unittest

from mock_kbase.clients.workspace import Workspace

class TestWorkspaceService(unittest.TestCase):
    def setUp(self):
        self.port = 7058
        self.token = os.environ['KB_AUTH_TOKEN']

    def test_workspace_service_up_anonymous(self):
        self.is_workspace_service_up()
    
    def test_workspace_service_up_authenticated(self):
        self.is_workspace_service_up(self.token)

    def is_workspace_service_up(self, token=None):
        url = "http://localhost:{}".format(self.port)

        if token:
            print "Testing workspace service at {} with auth".format(url)
            wc = Workspace(url, token=token)
        else:
            print "Testing workspace service at {} without auth".format(url)
            wc = Workspace(url)
        
        print "Checking workspace status..."
        status = wc.status()
        self.assertTrue(status['state'] == "OK",
                        "ERROR: Bad status indicator! {}".format(
                        json.dumps(status,
                                   sort_keys=True,
                                   indent=4,
                                   separators=(',', ': '))))
        for d in status['dependencies']:
            self.assertTrue(d['state'] == "OK",
                            "ERROR: Bad status indicator for {}! {}".format(
                            d['name'], d['state']))
        print "Checking for workspace type information..."
        type_info = wc.list_all_types({"with_empty_modules": 1})
        print json.dumps(type_info, sort_keys=True, indent=4, separators=(',', ': '))
        self.assertTrue(type_info is not None and len(type_info) > 0, 
                        "ERROR: Type information missing!")