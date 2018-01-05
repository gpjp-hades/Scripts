mkdir -p /opt/hades
mv start.sh /opt/hades
mv hades.service /lib/systemd/system
systemctl install hades
systemctl enable hades
systemctl start hades