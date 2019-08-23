#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
from urlparse import urlparse
from os import getenv
from sys import exit
from re import match
from json import dumps as jsondumps, loads as jsonloads
from argparse import ArgumentParser
from yaml import safe_dump
from datetime import datetime
from copy import deepcopy

__author__ = "Devops Store"
__copyright__ = "Orange"
__version__ = "2.0.0"
__email__ = "devops.store@orange.com"
__status__ = "Production"
__source__ = "https://gitlab.forge.orange-labs.fr/devops-store/ansible-dynamic-inventory-from-openstack-api"


class Api(object):
    @staticmethod
    def get_version(url):
        url_split = urlparse(url)
        url_path_split = url_split.path.split('/')
        if len(url_path_split) >= 2 and match('v\d', url_path_split[1]):
            return url_path_split[1]

    @staticmethod
    def post(url, data, insecure=False):
        # Request a response with json data
        try:
            response = requests.post(url, verify=not insecure, json=data)
        except requests.exceptions.SSLError:
            print("ERROR: certificate verify failed (Maybe you need to use OS_INSECURE=True)")
            print("")
            exit(1)
        # Check the status code and raise an error if not 200
        response.raise_for_status()
        # return a response in json
        return response.json()

    @staticmethod
    def post_credential(url, data, insecure=False):
        # Request a response with json data
        response = requests.post(url, verify=not insecure, json=data)
        # Check the status code and raise an error if not 200
        response.raise_for_status()
        valToReturn = response.json()
        if 'X-Subject-Token' in response.headers:
            valToReturn['X-Subject-Token'] = response.headers['X-Subject-Token']
        # return a response in json
        return valToReturn

    @staticmethod
    def get(url, token, insecure=False):
        # Request an api
        response = requests.get(url, verify=not insecure, headers=token)
        # Check the status code and raise an error if not 200
        response.raise_for_status()
        # return a response in json
        return response.json()


class OpenstackApi(object):
    def __init__(self, credentials):
        self.debug = credentials['debug']
        if self.debug:
            print("\n### Fetch token and URLs from API endpoint\n")
        self.service_url = self.get_token(credentials)
        self.inventory = dict()
        self.inventory['api'] = {'servers': False,
                                 'servers_detail': False,
                                 'images': False}

    def get_inventory(self):
        return self.inventory

    def get_token(self, c):
        url = {'service_catalog': dict()}
        # Define a dict for the api authentication method
        auth_data = dict()
        # Define the url for the api authentication method: keystone api
        url_token = '{}'.format(c['auth_url'])

        identity_version = Api.get_version(c['auth_url'])
        if identity_version[:2] == 'v2':
            if self.debug:
                print("Using API version 2")
            auth_data = {
                'auth': {
                    'passwordCredentials': {
                        'username': '{}'.format(c['user']),
                        'password': '{}'.format(c['password'])
                    },
                    'tenantId': '{}'.format(c['tenant_id'])
                }
            }
            url_token += '/tokens'
            # Request a token to keystone
            json_token = Api.post(url_token, auth_data, c['insecure'])

            if self.debug:
                print("\n### Show raw token ###\n")
                print(jsondumps(json_token, indent=2, sort_keys=True))

            # Store the token in service_url
            url['token'] = {'header': {'X-Auth-Token': json_token['access']['token']['id']}}
            url['token'].update({'issued_at': json_token['access']['token'].get('issued_at', datetime.now().isoformat())})
            url['token'].update({'expires': json_token['access']['token']['expires']})

            # Check region argument is not null (mendatory for api v2)
            if not c['region_name']:
                print("Error: the Region parameter is not set. This is mandatory for API version 2. Use env variable to set it like: export OS_REGION_NAME=fr1 \nSee Readme for more help.")
                exit(-1)

            service_catalog = json_token['access']['serviceCatalog']
            for service in service_catalog:
                for endpoint in service['endpoints']:
                    if endpoint['region'] == c['region_name']:
                        url['service_catalog'].update({service['type']: endpoint['publicURL']})

        elif identity_version[:2] == 'v3':
            if self.debug:
                print("Using API version 3")

            # Check domain argument is not null (mendatory for api v3)
            if not c['user_domain_name']:
                print("Error: the Domain is not set. This is mandatory for API version 3. Use env variable to set it like: export OS_USER_DOMAIN_NAME=default \nSee Readme for more help.")
                exit(-1)

            auth_data = {
                "auth": {
                    "identity": {
                        "methods": [
                            "password"
                        ],
                        "password": {
                            "user": {
                                "name": "{}".format(c["user"]),
                                "password": "{}".format(c["password"]),
                                "domain": {"name": "{}".format(c["user_domain_name"])}
                            }
                        }
                    },
                    "scope": {
                        "project": {
                            "id": "{}".format(c["tenant_id"]),
                            "domain": {"name": "{}".format(c["user_domain_name"])},
                        }
                    }
                }
            }
            url_token += '/auth/tokens'

            # Request a token to keystone
            json_token = Api.post_credential(url_token, auth_data, c['insecure'])

            if self.debug:
                print("\n### Show raw token ###\n")
                print(jsondumps(json_token, indent=2, sort_keys=True))

            # Store the token in service_url
            url['token'] = {'header': {'X-Auth-Token': json_token['X-Subject-Token']}}
            url['token'].update({'issued_at': json_token['token']['issued_at']})
            url['token'].update({'expires': json_token['token']['expires_at']})

            service_catalog = json_token['token']['catalog']
            for service in service_catalog:
                for endpoint in service['endpoints']:
                    if endpoint['interface'] == 'public':
                        url['service_catalog'].update({service['type']: endpoint['url']})
        else:
            print('This version of keystone api is not supported by this tool')
            exit(-1)

        # Store the insecure bool (retrieve by the os environment variable)
        url['insecure'] = c['insecure']

        if self.debug:
            print("\n### Show formated token ###\n")
            print(jsondumps(url, indent=2, sort_keys=True))
        return url

    def query_images(self):
        # Check if the api was already requested
        if self.inventory['api']['images']:
            return
        # Define the servers api
        s = self.service_url
        url_image = '{}/v1/images'.format(s['service_catalog']['image'])
        # Request the images lists
        json_images = Api.get(url_image, s['token']['header'], s['insecure'])
        # Store the fact that the api was requested
        self.inventory['api']['images'] = True
        # Store the result in the inventory dict
        self.inventory['images'] = json_images['images']

    def query_servers(self):
        # Check if the api was already requested
        if self.inventory['api']['servers']:
            return
        # Define the servers api
        s = self.service_url
        url_compute = '{}/servers'.format(s['service_catalog']['compute'])
        # Request the server lists
        json_servers = Api.get(url_compute, s['token']['header'], s['insecure'])
        # Store the fact that the api was requested
        self.inventory['api']['servers'] = True
        # Store the result in the inventory dict
        self.inventory['servers'] = json_servers['servers']

    def query_servers_detail(self):
        # Check if the api was already requested
        if self.inventory['api']['servers_detail']:
            return
        # Define the servers api
        s = self.service_url
        url_compute = '{}/servers/detail'.format(s['service_catalog']['compute'])
        # Request detailed servers
        json_servers = Api.get(url_compute, s['token']['header'], s['insecure'])
        # Store the fact that the api was requested
        self.inventory['api']['servers_detail'] = True
        # Store the fact the api was requested
        self.inventory['api']['servers'] = True
        # Store the result in the inventory dict
        self.inventory['servers_detail'] = json_servers['servers']


class AnsibleInventory(object):
    def __init__(self):
        pass

    class Openstack(object):
        def __init__(self, args):
            self.public_ip = args['public_ip']
            self.network = args['network']
            self.filter = args['filter']
            self.debug = args['debug']
            self.metadata = {'host_groups': ';', 'host_vars': ';'}
            self.oApi = OpenstackApi(args)

            if 'image' in args['object']:
                self.oApi.query_images()
                self.image = self.oApi.get_inventory()['images']
            elif 'server' in args['object']:
                self.oApi.query_servers_detail()
                self.inventory = self.generate_inventory(self.oApi.get_inventory()['servers_detail'])
                self.inventory['ini'] = self.generate_ini_inventory()

        def get_inventory_json(self):
            return self.inventory['json']

        def get_inventory_ini(self):
            return self.inventory['ini']

        def get_host_ip(self, hostname):
            if hostname not in self.inventory['json']['_meta']['hostvars']:
                print("Error: Cannot get ip address, host '" + hostname + "' not found in the inventory!")
                exit(-1)
            return self.inventory['json']['_meta']['hostvars'][hostname]['ansible_host']

        def get_image_yaml(self):
            return self.image

        def is_metadata_filtered(self, key=None, value=None):
            if self.filter is None:
                return True

            for f in self.filter:
                for k, v in f.iteritems():
                    if k == key:
                        if v == value:
                            return True

            return False

        def generate_inventory(self, servers_detail):
            inv = dict()
            inv['_meta'] = {'hostvars': {}}
            host_filtered = []

            if self.debug:
                print("\n### Show raw servers details from json object ###\n")
                print(jsondumps(servers_detail, indent=2, sort_keys=True))

            # Sort servers by name
            servers_detail = sorted(servers_detail, key=lambda i: i["name"])

            for server in servers_detail:
                host = server['name']
                host_ip = None
                host_vars = {}

                # By default all host of the tenant will be in the "all" group inventory
                inv = self.add_server_to_host_group("all", host, inv)
                # Update the hosts filtered if needed
                if self.is_metadata_filtered() and not host_filtered.count(host):
                    host_filtered.append(host)

                # Set the ip if exists in the inventory
                # Filter on the network name
                if self.network in server['addresses']:
                    # Get the public ip wanted
                    if self.public_ip:
                        for ip in server['addresses'][self.network]:
                            if 'floating' in ip['OS-EXT-IPS:type']:
                                host_ip = ip['addr']
                                break

                    # Otherwise get the private ip (also if public ip does not exist)
                    if not self.public_ip or not host_ip:
                        for ip in server['addresses'][self.network]:
                            if 'fixed' in ip['OS-EXT-IPS:type']:
                                host_ip = ip['addr']
                                break

                # Set the ansible_host inventory vars if @IP has been retrieve
                if host_ip:
                    host_vars['ansible_host'] = host_ip
                    inv = self.add_server_to_host_vars(host_vars, host, inv)

                # Filter the server by metadata
                metadata = server['metadata']
                # if metadata is empty, break
                if not metadata:
                    continue

                for k, v in metadata.iteritems():
                    if 'host_groups' == k:
                        # Group hosts in an inventory group
                        for group in metadata[k].split(self.metadata[k]):
                            inv = self.add_server_to_host_group(group, host, inv)
                            # Update the hosts filtered if needed
                            if self.is_metadata_filtered(k, group) and not host_filtered.count(host):
                                host_filtered.append(host)

                    # Get the variables from the metadata
                    elif 'host_vars' == k:
                        for kv in metadata[k].split(self.metadata[k]):
                            if kv and kv != "":
                                if ("->" in kv):
                                    kv_separator = "->"
                                elif ("=" in kv):
                                    kv_separator = "="
                                else:
                                    print("Error: the host_vars '" + kv + "' should be formatted like key->value or key=value, correct this in your Terraform stack")
                                    exit(-1)
                                key, values = kv.split(kv_separator)
                                host_vars[key] = values
                                # Update the hosts filtered if needed
                                if self.is_metadata_filtered(k, kv) and not host_filtered.count(host):
                                    host_filtered.append(host)
                                inv = self.add_server_to_host_vars(host_vars, host, inv)

                    else:
                        # Update the hosts filtered if needed
                        if self.is_metadata_filtered(k, v) and not host_filtered.count(host):
                            host_filtered.append(host)

            inv = self.filter_hosts(inv, host_filtered)
            inventory = dict()
            inventory['json'] = inv
            return inventory

        def filter_hosts(self, inventory, host_filtered):
            inv = deepcopy(inventory)
            meta = '_meta'
            hosts = 'hosts'

            for h in inventory[meta]['hostvars']:
                if h not in host_filtered:
                    inv[meta]['hostvars'].pop(h, None)

            for k in sorted(inventory):
                if k != meta:
                    for h in inventory[k][hosts]:
                        if h not in host_filtered:
                            inv[k][hosts].remove(h)

            for k in sorted(inventory):
                if k != meta and len(inv[k][hosts]) == 0:
                    inv.pop(k, None)

            return inv

        @staticmethod
        def add_server_to_host_group(group, server, inventory):
            host_groups = inventory.get(group, {})
            hosts = host_groups.get('hosts', [])
            hosts.append(server)
            host_groups['hosts'] = hosts
            inventory[group] = host_groups
            return inventory

        @staticmethod
        def add_server_to_host_vars(host_vars, server, inventory):
            meta = '_meta'
            hostvars = 'hostvars'
            inventory_host_vars = inventory[meta][hostvars].get(server, {})
            inventory_host_vars.update(host_vars)
            inventory[meta][hostvars][server] = inventory_host_vars
            return inventory

        @staticmethod
        def search_server_in_host_vars(inventory, host):
            meta = '_meta'
            hostvars = 'hostvars'
            hostmeta = host
            if meta in inventory:
                if hostvars in inventory[meta]:
                    if host in inventory[meta][hostvars]:
                        for k in inventory[meta][hostvars][host]:
                            hostmeta += ' ' + k + '=' + inventory[meta][hostvars][host][k]
            return hostmeta

        def generate_ini_inventory(self, group=None, rename=None):
            meta = '_meta'
            hosts = 'hosts'
            inventory_ini = ''
            for k in sorted(self.inventory['json']):
                if group and group in self.inventory['json']:
                    if k == group:
                        if rename:
                            inventory_ini += "[{}]\n".format(rename)
                            for h in self.inventory['json'][k][hosts]:
                                inventory_ini += "{}\n".format(
                                    self.search_server_in_host_vars(self.inventory['json'], h))
                        else:
                            inventory_ini += "[{}]\n".format(k)
                            for h in self.inventory['json'][k][hosts]:
                                inventory_ini += "{}\n".format(
                                    self.search_server_in_host_vars(self.inventory['json'], h))
                else:
                    if k != meta:
                        inventory_ini += "[{}]\n".format(k)
                        for h in self.inventory['json'][k][hosts]:
                            inventory_ini += "{}\n".format(
                                self.search_server_in_host_vars(self.inventory['json'], h))
            return inventory_ini


def get_os_env():
    env = dict()
    os_env = {'user': {'env': 'OS_USERNAME', 'default': None, 'mandatory': True},
              'password': {'env': 'OS_PASSWORD', 'default': None, 'mandatory': True},
              'tenant_id': {'env': 'OS_TENANT_ID', 'default': None, 'mandatory': True},
              'auth_url': {'env': 'OS_AUTH_URL', 'default': None, 'mandatory': True},
              'region_name': {'env': 'OS_REGION_NAME', 'default': None, 'mandatory': False},
              'user_domain_name': {'env': 'OS_USER_DOMAIN_NAME', 'default': None, 'mandatory': False},
              'network': {'env': 'OS_NETWORK_NAME', 'default': None, 'mandatory': True},
              'insecure': {'env': 'OS_INSECURE', 'default': False},
              'format': {'env': 'AS_format', 'default': 'json'},
              'object': {'env': 'AS_object', 'default': 'server'},
              'filter': {'env': 'AS_filter', 'default': None},
              'public_ip': {'env': 'AS_public_ip', 'default': False}}

    for key, value in os_env.iteritems():
        if getenv(value['env']) is not None:
            env[key] = getenv(value['env'])
        elif 'mandatory' in value and value['mandatory']:
            print("ERROR: environment variable {} is not defined".format(value['env']))
            exit(-1)
        else:
            env[key] = os_env[key]['default']

    # Desactive les warnings du module requests en mode insecure
    if env['insecure']:
        from requests.packages.urllib3.exceptions import InsecureRequestWarning
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    return (env, os_env)


def parse_args():

    (args, os_env) = get_os_env()

    # Get the value from the script arguments
    parser = ArgumentParser(description="Openstack inventory module")
    parser.add_argument("--format", choices=["json", "ini"], help="Format of the inventory output (default=json)")
    parser.add_argument("--object", choices=["server", "image"], help="List active servers or image for a defined tenant (default=server)")
    parser.add_argument("--filter", nargs='+', metavar="'{\"key\": \"value\"}'", type=str, help="Set one or more filter on the metadata")
    parser.add_argument("--list", action="store_true", help="List active servers")
    parser.add_argument("--public-ip", action="store_true", help="Use floating ip address for ansible host (by default private ip is used)")
    parser.add_argument("--get-host-ip", metavar='hostname', help="Return the IP address of the given hostname")
    parser.add_argument("--debug", action="store_true", help="Show debug informations")

    # Now override os env variable by script arguments if needed
    # script arguments always win !
    if parser.parse_args().format is not None:
        args['format'] = parser.parse_args().format

    if parser.parse_args().object is not None:
        args['object'] = parser.parse_args().object

    if parser.parse_args().filter is not None:
        try:
            f_list = []
            for f in parser.parse_args().filter:
                tmp = jsonloads(f)
                if not f_list.count(tmp):
                    f_list.append(tmp)
            args['filter'] = f_list
        except:
            print("filter must be a json string")
            print("")
            parser.print_help()
            exit(1)
    else:
        # Convert string to list
        try:
            if args['filter'] is not None:
                args['filter'] = list([jsonloads(args['filter'])])
        except:
            print("filter must be a json string")
            print("")
            parser.print_help()
            exit(1)

    if parser.parse_args().public_ip:
        args['public_ip'] = parser.parse_args().public_ip

    if parser.parse_args().get_host_ip is not None:
        args['get_host_ip'] = parser.parse_args().get_host_ip

    if parser.parse_args().debug:
        args['debug'] = True
    else:
        args['debug'] = False

    return args


def main():
    args = parse_args()
    if args['debug']:
        print("Debug mode enabled")
        args_safe = args.copy()
        args_safe['password'] = "XXXXXX"
        print("Script arguments (hiding password):")
        print(args_safe)
    ansible_inventory = AnsibleInventory.Openstack(args)
    if args['object'] == 'server':
        if args['format'] == 'json':
            if 'get_host_ip' in args:
                print(ansible_inventory.get_host_ip(args['get_host_ip']))
            else:
                print(jsondumps(ansible_inventory.get_inventory_json(), sort_keys=True, indent=2))
        elif args['format'] == 'ini':
            print(ansible_inventory.get_inventory_ini())
    elif args['object'] == 'image':
        img = list()
        for i in ansible_inventory.get_image_yaml():
            img.append(i['name'])
        print(safe_dump(img, default_flow_style=False))

    # Retrieve program args
    exit(0)


if __name__ == '__main__':
    main()
