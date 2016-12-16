# mock_kbase
A fully functional packaging of the KBase data platform 
to facilitate unit testing and integration testing.

<a name="toc"></a>
# Table of Contents  
* [KBase SDK module testing](#sdk_test)  
* [Mock container only testing](#mock_test)
* [Mock container services exposed](#mock_services)
* [Mock container internals](#mock_inspect)  

<a name="sdk_test"></a>
## Steps for using the mock container with a KBase SDK module

### 1. Checkout, build, and start the mock container
```
git clone https://github.com/kbaseIncubator/mock_kbase
cd mock_kbase
docker build -t mock_kbase .
docker network create kbtest
docker run -p 8099:80 -e KB_USER="<kbase_username>" -e KB_PASS="<kbase_password>" -e KB_INSTANCE="ci" --name mock_kbase mock_kbase
```

### 2. Configure the KBase SDK module test_local/test.cfg
```kbase_endpoint=http://<your IP address>:8099/services```

### 3. Run KBase SDK module tests as usual
```kb-sdk test```

<a name="mock_test"></a>
## Testing the mock container itself
[Back to Table of Contents](#toc)

### 1. Run the container to test directly against service ports
```docker run -p 3306:3306 -p 7044:7044 -p 7058:7058 -p 7109:7109 --name mock_kbase mock_kbase```

### 2. Install python testing code
```
virtualenv venv
source venv/bin/activate
python setup.py install
```

### 3. Set KBase Auth token for tests
```export KB_AUTH_TOKEN="paste token here"```

### 4. Run basic included tests
```python setup.py test```

<a name="mock_services"></a>
## More about the mock container
[Back to Table of Contents](#toc)

### Accessing services from the mock container
  You can map each service to a local port of your choice via the docker run command.
  ```docker run -p <optional IP address>:<destination port>:<container port>```

#### Currently exposed ports:
  * SHOCK - 7044
  * Workspace - 7058
  * Handle - 7109
  * MySQL - 3306
  * MongoDB - 27017
  * Nginx - 80 + 443

#### KBase services are also accessible locally (using KBase url conventions) from:
  * http://(host):(port)/services/
  * https://(host):(port)/services/
      - host can be localhost OR your current IP
          - NOTE: kb-sdk *requires* your IP, localhost will not work
      - port is what was mapped from the container
          - e.g.; 80 is mapped above to 8099, 443 is mapped to 8100
  * SHOCK - /services/shock-api/
  * Workspace - /services/ws/
  * Handle - /services/handle_service/
  
  It may be sufficient for KBase SDK module tests to simply map to the
  HTTP or HTTPS port.  However, please see the Handle service section
  for a note about test cleanup.

### Testing the SHOCK service directly
  SHOCK is running on port 7044, which you can map to a host port of your choice.
  SHOCK uses a combination of MongoDB and files on disk.  You can specify a local
  directory to mount as the SHOCK data volume, which will then contain any files
  uploaded into SHOCK.
  
  ```docker run -v <my_directory>:/usr/local/shock/data ...```
  
  The SHOCK API reference is available here [https://github.com/MG-RAST/Shock/wiki/API](https://github.com/MG-RAST/Shock/wiki/API)

### Testing the KBase Handle service directly
  The KBase Handle service runs on port 7109, and stores data in MySQL.
  The service spec for reference: [https://github.com/kbase/handle_service/blob/master/handle_service.spec](https://github.com/kbase/handle_service/blob/master/handle_service.spec)

  * MySQL account info
    - (admin) user: root, password: root
    - (handle service user) user: hsi, password: hsi-pass

  NOTE: Manual MySQL cleanup is necessary at the moment if you want to run
  multiple tests and have a clean MySQL DB for each test.  The service does
  not implement a delete method, so rows will persist unless manually removed
  directly from MySQL.  MySQL is exposed at port 3306.
  See lib/mock_kbase/test/test_handle_service.py for example cleanup.

### Testing the KBase Workspace service directly
  The KBase Workspace service runs on port 7058 and stores data in MongoDB.
  
  The Workspace and Handle Manager (internal to the container) both require 
  configuration of a KBase user account authentication (user/password for now, 
  eventually tokens).  This user information is specified as part of the docker 
  run using environment variables KB_USER and KB_PASS.  Those strings are then 
  substituted into the service configuration before the services are started.

<a name="mock_inspect"></a>
## Inspecting the mock container internals
[Back to Table of Contents](#toc)

You can enter the running mock container as follows:
```docker exec -it mock_kbase bash```

### Logs
* Service startup logs 
    - /var/log/supervisor/
    - mysql.log, mongodb.log, nginx.log, supervisord.log, 
      shock.log, workspace.log, handle\_service.log, handle\_manager.log,
      init\_kbase.log
* MySQL log
    - /var/log/mysql/error.log
* MongoDB log
    - /var/log/mongodb/mongodb.log
* SHOCK running logs 
    - /usr/local/shock/logs/
    - access.log, error.log, perf.log
* Handle running logs
    - /kb/deployment/services/handle_service/
    - access.log, error.log
* Handle manager running logs
    - /kb/deployment/services/handle_mngr/
    - access.log, error.log
* Workspace running log
    - /kb/deployment/services/workspace/glassfish_domain/Workspace/logs/server.log