import json
import requests
import os
import boto3
import csv

url = 'https://test.com/api'


def generate_access_token():
    client_id = os.environ['client_id']
    client_secret = os.environ['client_secret']

    scope = f'api://{client_id}/.default'

    token_url = url + '/oauth2/token'

    d = {
        "client_id": client_id,
        "scope": scope,
        "client_secret": client_secret,
        "grant_type": "client_credentials",
    }

    r = requests.post(token_url, data=d)

    return r.json()['access_token']


def generate_payload(user: str, mail: str):
    return json.dumps({
        "schemas": [
            "urn:ietf:params:scim:schemas:core:2.0:User"
        ],
        "externalId": f"{mail}",
        "userName": f"{mail}",
        "active": True,
        "emails": [
            {
            "primary": True,
            "type": "work",
            "value": f"{mail}"
            }
        ],
        "meta": {
            "resourceType": "User"
        },
        "name": {
            "formatted": f"{user}",
            "familyName": "",
            "givenName": f"{user}"
        },
        "roles": [],
        "displayName": f"{user}"
    })


def launch_create_request(user: str, mail: str):
    token = generate_access_token()
    request_url = url + "/scim/v2/tenant/9143/Users/"
    print(f'Create user with login: {user} and mail: {mail}')

    payload = generate_payload(user, mail)

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }

    response = requests.request("POST", request_url, headers=headers, data=payload)
    print(response.text)


def launch_delete_request(user_id: str):
    token = generate_access_token()
    request_url = url + f"/scim/v2/tenant/9143/Users/{user_id}"
    print(f'Delete user with id: {user_id}')

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }

    response = requests.request("DELETE", request_url, headers=headers, data="")
    print(response.text)


def manage_users_csv(s3_object, is_user_creation: bool):
    data = s3_object.get()['Body'].read().decode('utf-8').splitlines()

    csv_reader = csv.reader(data, delimiter=';')
    
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Column names are: {", ".join(row)}')
            line_count += 1
        else:
            launch_create_request(row[0], row[1]) if is_user_creation else launch_delete_request(row[0])
            line_count += 1


def is_user_creation(key: str) -> bool:
    return True if key == "create_users.csv" else False


def manage_s3_object(event):
    key = event['detail']['object']['key'] #  create_users.csv or delete_users.csv
    bucket = event['detail']['bucket']['name'] # s3-eventbridge-api-bucket

    try:
        s3_resource = boto3.resource('s3')
        s3_object = s3_resource.Object(bucket, key)

    except Exception as err:
        print(err)

    manage_users_csv(s3_object, is_user_creation(key))


def lambda_handler(event, context):
    manage_s3_object(event)