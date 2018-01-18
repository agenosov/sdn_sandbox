### API Server plus all related stuff

* ./controller/src/config/api-server - the API server in Python (*contrail-api service*)
    - ./vnc_cfg_api_server.py implements the main entry point for configuration server

* ./controller/src/api-lib - the Python library to communicate with API server


### Analytics

* ./controller/src/analytics/contrail-broadview - daemon on analytics node to periodically poll switches

* ./controller/src/opserver - analytics API implementation
    - ./opserver.py implements the main entry point for *contrail-analytics-api service*
