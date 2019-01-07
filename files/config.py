# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
This file contains all of the configuration values for the application.
Update this file with the values for your specific Google Cloud project.
You can create and manage projects at https://console.developers.google.com
"""

import hvac
from string import Template

# Get pod Token
f = open('/var/run/secrets/kubernetes.io/serviceaccount/token')
jwt = f.read()

# Initialize the client
client = hvac.Client()
client = hvac.Client(url='${vault_address}',verify=False)

# k8s authenticate using token
auth = client.auth_kubernetes("k8s-role", jwt)

# Get secrets
secret = client.read('kv/bookshelf').get('data')

# Fetch a database credential from Vault DB endpoint
creds = client.read('db/creds/dev')

# Fetch corresponding client_token, data and lease_id
vault_token = auth.get('auth').get('client_token')
creds_data = creds.get('data')
creds_lease_id = creds.get('lease_id')

# Logout
client.logout()

# Store vault token for sidecar renewal
vault_token_file = open("/etc/vault-assets/vault_token", mode="w")
vault_token_file.write(vault_token)
vault_token_file.close()

# Store lease_id for sidecar renewal
creds_lease_id_file = open("/etc/vault-assets/lease_id", mode="w")
creds_lease_id_file.write(creds_lease_id)
creds_lease_id_file.close()

# There are two different ways to store the data in the application.
# You can choose 'datastore', or 'cloudsql'. Be sure to
# configure the respective settings for the one you choose below.
# You do not have to configure the other data backend. If unsure, choose
# 'datastore' as it does not require any additional configuration.
DATA_BACKEND = 'cloudsql'

# Google Cloud Project ID. This can be found on the 'Overview' page at
# https://console.developers.google.com
PROJECT_ID = secret.get('project_id')

# SQLAlchemy configuration
# Replace user, pass, host, and database with the respective values of your
# Cloud SQL instance.
sql_template = \
    Template("mysql+pymysql://$username:$password@$host/$database")

SQLALCHEMY_DATABASE_URI = sql_template.substitute( \
	                      username=creds_data.get('username'), \
	                      password=creds_data.get('password'), \
	                      host=secret.get('host'), \
	                      database=secret.get('database'))

# Google Cloud Storage and upload settings.
# Typically, you'll name your bucket the same as your project. To create a
# bucket:
#
#   $ gsutil mb gs://<your-bucket-name>
#
# You also need to make sure that the default ACL is set to public-read,
# otherwise users will not be able to see their upload images:
#
#   $ gsutil defacl set public-read gs://<your-bucket-name>
#
# You can adjust the max content length and allow extensions settings to allow
# larger or more varied file types if desired.
CLOUD_STORAGE_BUCKET = "bookshelf-k8s-demo"
MAX_CONTENT_LENGTH = 8 * 1024 * 1024
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])