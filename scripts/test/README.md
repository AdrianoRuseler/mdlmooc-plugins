## EC2 User Data
```bash
#!/bin/bash

wget https://raw.githubusercontent.com/AdrianoRuseler/mdlmooc-plugins/master/scripts/test/userdata-test-ubuntu.sh
chmod u+x userdata-test-ubuntu.sh
sudo ./userdata-test-ubuntu.sh

wget https://raw.githubusercontent.com/AdrianoRuseler/mdlmooc-plugins/master/scripts/test/mooshinstall.sh
chmod u+x mooshinstall.sh
sudo ./mooshinstall.sh
```
