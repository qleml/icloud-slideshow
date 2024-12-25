# photo-stream
Mum's christmas gift

Install icloudpd

in the crontab -u ccc -e 

# Everyday at 2:00
#0 18 * * * /bin/bash ~/dev/photo-stream/scripts/fetch_media.sh

@reboot /bin/bash -c "sleep 10; /home/ccc/dev/photo-stream/scripts/run_feh>
# Every 5 minutes

*/1 * * * * /bin/bash /home/ccc/dev/photo-stream/scripts/fetch_media.sh
