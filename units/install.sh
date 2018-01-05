mkdir -p /opt/hades
cp start.sh /opt/hades
cp hades.service /lib/systemd/system
sudo systemctl enable --now hades