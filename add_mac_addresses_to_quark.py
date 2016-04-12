#!/usr/bin/env python

import requests
import json

HOST = "127.0.0.1"
API_VERSION = "v2.0"
ADMIN_PASSWORD = "password"

url = "http://%s:%s/%s/tokens" % (HOST, "5000", API_VERSION)
data = {'auth': {'tenantName': 'admin', 'passwordCredentials': {'username': 'admin', 'password': ADMIN_PASSWORD}}}
headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'User-Agent': 'python-neutronclient'}
r = requests.post(url, data=json.dumps(data), headers=headers)
content = json.loads(r.content)
if not content or not content.get("access"):
    print("No content back from trying to get a token")
token = content["access"]["token"]["id"]

url = "http://%s:%s/%s/mac_address_ranges.json" % (HOST, "9696", API_VERSION)
headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'User-Agent': 'python-neutronclient', 'X-Auth-Token': token}
data = {'mac_address_range': {'cidr': 'AA:BB:CC'}}
r = requests.post(url, data=json.dumps(data), headers=headers)
content = json.loads(r.content)
if not content:
    print("No content back from trying add mac address range")
print(content)
