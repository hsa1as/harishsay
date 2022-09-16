#/bin/sh
filelist='./harishs'
apt install perl
chmod +x harishsay
cp ./harishsay.pl /usr/share/
cp ./harishsay /bin/
mkdir /usr/share/harishs
tar -cf - $filelist | (cd /usr/share && tar -xvf -)

