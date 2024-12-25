# 🎁 Mom's Christmas Gift

Take your old laptop and turn it into the perfect gift for your parents: 

### A slideshow that syncs with your iCloud photos every night! 

* Syncs with your iCloud library at a chosen interval 
* Runs the slideshow automatically on reboot 
* Shows the x most recent photos and maintains storage limits 

## Get it running in 5 simple steps (~1 hour) ⏳

1. **Install an Ubuntu version** on your old laptop. For older laptops with resource constraints, I would recommend Lubuntu: [Download Lubuntu](https://lubuntu.me/downloads/).
2. Once running, in the folder of your choice, clone this repo:
   ```bash
   git clone https://github.com/qleml/icloud-slideshow.git
   ```
3. Navigate to the project directory and run the following:
   ```bash
   cd icloud-slideshow
   sudo chmod +x scripts/*
   ./scripts/setup.sh
   ```
   This will:
   * Store the path of this directory in `$ICLOUD_SLIDESHOW_PATH` and append it to the `~/.bashrc` file.
   * Create a virtual environment called `venv` and install the necessary packages (`icloudpd`, `feh`, `pyyaml`, etc.).
   * Create a cron job to fetch your photos every day at 3 AM and start the slideshow automatically on reboot.
   
4. **Login with your Apple ID** and complete 2FA by running:
   ```bash
   ./scripts/authenticate.sh
   ```
   Follow the prompts to authenticate. 

5. **Customize the settings** in the `config/config.yaml` file to match your preferences and to specify your Apple ID email!

To check if everything is working, you can manually start 
  ```bash
   ./scripts/fetch_media.sh
   ./scripts/run_feh.sh
   ```

---

## ⚙️ Customization

#### Change the update frequency 

To adjust how often your photos sync, open the cron file with:
```bash
crontab -u
```

Then modify the schedule:
- At X o'clock every day:
   ```bash
   0 X * * * /bin/bash $ICLOUD_SLIDESHOW_PATH/scripts/fetch_media.sh
   ```

- Every X hours:
   ```bash
   0 */X * * * $ICLOUD_SLIDESHOW_PATH/scripts/fetch_media.sh
   ```

#### Change the slideshow interval 

To adjust the slideshow speed, open the `scripts/run_feh.sh` file and modify the interval `X`:
```bash
feh --slideshow-delay 7 --recursive -F $ICLOUD_SLIDESHOW_DIR media
```

---

## ⚠️ Limitations

The functionality is still limited and could be improved. Here are some things to keep in mind:

- **Keyring password**: After rebooting, the script may ask for your keyring password since the Apple ID password is stored in the keyring. If the only purpose of the laptop is this application in a safe environment (e.g., your home), you may want to set a blank password for the keyring. Alternatively, one could implement a safer solution.
- **Photo downloading**: Every night, the script downloads all photos, even if they have already been downloaded before. One can fix this by checking which files have already been downloaded using the `--only-print-filenames` flag.
- **Re-authentication**: After 2 months, you need to manually re-authenticate using the `./scripts/authenticate.sh` script. This can be solved by using an authentication system through a secure messenger service, similar to how [docker-icloudpd](https://github.com/boredazfcuk/docker-icloudpd) does it.
- **Videos**: The script currently only fetches photos, not videos.

---

Enjoy the slideshow! 🎄✨
