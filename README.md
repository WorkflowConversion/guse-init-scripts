# gUSE/WS-PGRADE initialization scripts
In order to automate deploying and testing, I adapted these scripts. Previous versions installed gUSE as a Linux service, but I changed it so it all runs under the default user `guseuser`.

## Usage
  - Log-in (via SSH) to the machine where the WS-PGRADE portlet is running.
  - Make sure you are logged-in as `guseuser`.
  - Clone this repository on the home folder.
  
Make sure you end up with the scripts under the `~/guse-init-scripts` folder. I know this is tedious, but it's quite practical to be able to restart gUSE remotely if proper credentials are used via ssh (to enable passwordless authentication).
