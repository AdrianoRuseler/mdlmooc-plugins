## EC2 User Data
```bash
#!/bin/bash

wget https://raw.githubusercontent.com/AdrianoRuseler/mdlmooc-plugins/master/scripts/test/userdata-test-ubuntu.sh
chmod u+x userdata-test-ubuntu.sh
sudo ./userdata-test-ubuntu.sh | tee userdata-test-ubuntu.log
```