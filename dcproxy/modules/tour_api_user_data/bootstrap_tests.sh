#!/bin/bash
sleep 10
curl -sL -w "%{url_effective} %{http_code}\\n" "http://localhost/tropics/TropicsWS" -o /dev/null > /var/log/bootstrap-tests.log
curl -sL -w "%{url_effective} %{http_code}\\n" "http://localhost/tropics/TropicsBuildWS" -o /dev/null >> /var/log/bootstrap-tests.log
curl -sL -w "%{url_effective} %{http_code}\\n" "http://localhost/tropics/CustomerSyncWS" -o /dev/null >> /var/log/bootstrap-tests.log
curl -sL -w "%{url_effective} %{http_code}\\n" "http://localhost/DataAccessServices/OracleDataService.svc" -o /dev/null >> /var/log/bootstrap-tests.log
curl -sL -w "%{url_effective} %{http_code}\\n" "http://localhost" -o /dev/null >> /var/log/bootstrap-tests.log
