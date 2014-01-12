#!/bin/bash

# parts copied from:
# https://github.com/jedi4ever/veewee/tree/master/templates/freebsd-9.1-RELEASE-amd64

if [ "$USER" != "root" ]
then
    echo "ERROR: you must be root to run this command"
    exit 1
fi

hostname=$1
if [ -z "$hostname" ]
then
    echo "FATAL: hostname not specified"
    echo
    echo "  usage: $0 <hostname>"
    exit 1
fi

echo
echo "#############################################################################"
echo "setting hostname to $hostname..."
hostname $hostname

echo
echo "#############################################################################"
echo "setting date and time..."
ntpdate -v -b in.pool.ntp.org

echo
echo "#############################################################################"
echo "installing freebsd security updates..."

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

echo

echo "...Fetching OS updates..."
/usr/bin/env PAGER="/bin/cat" /tmp/freebsd-update fetch

echo "...Installing OS updates..."
/usr/bin/env PAGER="/bin/cat" /tmp/freebsd-update install

echo "...Done installing OS updates..."
echo

echo
echo WARNING: you should reboot now if any kernel patches were applied!!!
echo
sleep 5
echo

echo
echo "#############################################################################"
echo "updating the ports tree..."

# allow portsnap to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap

# get new ports
echo
echo "...Fetching updates to ports tree..."
/tmp/portsnap fetch extract || exit 1
echo "...Done fetching updates to ports tree..."

pkg_delete -af

echo
echo "#############################################################################"
echo "temporarily disabling x11 in make.conf..."
echo 'WITHOUT_X11="YES"' >> /etc/make.conf

echo
echo "#############################################################################"
echo "installing puppet from ports tree..."
cd /usr/ports/sysutils/puppet || exit 1
make -DBATCH install clean || exit 1

echo
echo "#############################################################################"
echo "fixing broken freebsd package provider"
cp /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb.orig
sed -i.bak "s|package_uri.to_s|package_uri.to_s.gsub\!( \/\\\%2F\/, '' )|" /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb

echo
echo "#############################################################################"
echo "installing zsh..."
cd /usr/ports/shells/zsh || exit 1
make -DBATCH install clean || exit 1

echo
echo "#############################################################################"
echo "generating a new ssh key for root..."
mkdir /root/.ssh
ssh-keygen -t dsa -P "" -f /root/.ssh/id_dsa
cat /root/.ssh/id_dsa.pub || exit 1

echo
echo "#############################################################################"
echo "removing temporary make.conf..."
rm /etc/make.conf || exit 1

echo
echo
echo "#############################################################################"
echo "Bootstrapped successfully"
echo

echo "Connecting to puppet to finish configuration...\n\n";
echo puppet agent -v --server puppetmaster --waitforcert 60 --test
puppet agent -v --server puppetmaster --waitforcert 60 --test


echo
echo "Puppet run complete..."
echo

