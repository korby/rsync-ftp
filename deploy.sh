#!/bin/bash
user_id=$(id -u `whoami`)
user_gid=$(id -g `whoami`)
ftp_host="ftp.host.org"
ftp_user="ftp-user"
ftp_password="ftp-pwd"
local_dir="/path/to/local/work/"
remote_root_dir="/path/to/ftp/mounted/"
remote_target_dir="www"
# -c option would force rsync to use checksum for comparison instead date and filesize, but it's long, so long...
rsync_command="rsync -rn --out-format='put %n "$remote_target_dir"/%n' > .transfert --size-only --filter='merge .rsyncfilter' $local_dir $remote_root_dir$remote_target_dir"

if [ ! -d  $remote_root_dir ]
then
    mkdir $remote_root_dir
fi
if [ $(( $(ls -a1 $remote_root_dir | wc -l) >= 3 )) = 0 ]
then
    # umount $remote_root_dir
    curlftpfs -o allow_other -o rw -o uid=$user_id -o gid=$user_gid $ftp_host $remote_root_dir -o user=$ftp_user:$ftp_password
fi

eval ${rsync_command}

cat .transfert | cut -d" " -f 2

read -p "Do you want to upload these files [N,y]?" resp

if [ "$resp" == "y" ] ; then
    ftp ftp://$ftp_user:$ftp_password@$ftp_host < .transfert
else
	echo "Aborting..."
fi
