# dst

## setup

```sh
sudo useradd -d /home/dst -g games -M -N -s /bin/bash -u 9998
sudo chown -R dst:games /home/dst
sudo chmod g+rw /home/dst
sudo chmod g+rwx /home/dst/bin/*.sh
```