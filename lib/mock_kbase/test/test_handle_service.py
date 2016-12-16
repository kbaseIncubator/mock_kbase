import os
import json
import unittest

import mysql.connector

from mock_kbase.clients.AbstractHandleClient import AbstractHandle

class TestHandleService(unittest.TestCase):
    def setUp(self):
        self.port = 7109
        self.token = os.environ['KB_AUTH_TOKEN']
        self.mysql_options = {
            "user": "hsi",
            "password": "hsi-pass",
            "database": "hsi"
        }

    def test_handle_service_up(self, port=None, token=None):
        if port is None:
            port = self.port
        if token is None:
            token = self.token

        url = "http://localhost:{}".format(port)
        print "Testing handle service at {}".format(url)

        hs = AbstractHandle(url, token=token)
        available_handles = hs.list_handles()
        self.assertTrue(available_handles is not None)
        print "Number of available handles: {}".format(len(available_handles))

        test_handle = hs.new_handle()
        fetch_handle = hs.ids_to_handles([test_handle["id"]])[0]
        print "New handle: {}".format(json.dumps(test_handle,
                                                 sort_keys=True,
                                                 indent=4,
                                                 separators=(',',':')))
        print "Fetched by id handle: {}".format(json.dumps(fetch_handle,
                                                           sort_keys=True,
                                                           indent=4,
                                                           separators=(',',':')))
        self.assertTrue(test_handle["hid"] == fetch_handle["hid"],
                        "ERROR: handle ids do not match".format(
                        test_handle, fetch_handle))
        # no delete from handle_service, so must connect via mysql to delete
        try:
            print "Deleting test handles..."
            cnx = mysql.connector.connect(**self.mysql_options)
            cursor = cnx.cursor()
            for hid in [test_handle["hid"], fetch_handle["hid"]]:
                query = ("DELETE FROM Handle WHERE hid = {}".format(int(hid.split('_')[1])))
                cursor.execute(query)
            cnx.commit()
            query = ("SELECT * FROM Handle")
            cursor.execute(query)
            rows = cursor.fetchall()
            print "Number of available handles: {}".format(len(rows))
            cursor.close()
            cnx.close()
        except mysql.connector.Error as err:
            if err.errno == mysql.connector.errorcode.ER_ACCESS_DENIED_ERROR:
                print "access denied for {}:{}".format(self.mysql_options["user"],
                                                       self.mysql_options["password"])
            elif err.errno == mysql.connector.errorcode.ER_BAD_DB_ERROR:
                print "database {} not found".format(self.mysql_options["database"])
            else:
                print err
        finally:
            try:
                cursor.close()
                cnx.close()
            except:
                pass
