#!/bin/bash

# parts copied from:
# https://github.com/jedi4ever/veewee/tree/master/templates/freebsd-9.1-RELEASE-amd64

pubkey="ssh-dss AAAAB3NzaC1kc3MAAACBAIaar22dY0yhqL0pF7m2N3xOFXZmWiFfdMTbZpgTCSzzVh8lC+GOe+LuV+WP2t+9gHBA+1VCeDBZ/4PsTbizUqmjFt3pZ2HDroO0Bibp6rcaAe+LCb3a9j+7YqZ7Y+2joiw6e4i1TqiXzDXC0UZsQMqHf840VodV1ndUkAAHkMh5AAAAFQCIj7gS7aaRMS9loYnvjTPIqm+gHwAAAIBkIdo0wi5vnxGPVb0cbjNeyDFh1Obze2CAFBgOBfWzPeGDPwxEkjBxM7uW1b4u0EWT/E2UVOy/+hvBsJvFvaFrPCFNOk3OJTI+IpYDCkn51L5+kFRS5TP746hyzSf8g0HtqcGoEO/CpioQrQL5B2z/uPsO7dy2MM0GG4GF1sN/NQAAAIAHv3SfroD0wKYC+H8r37M55f1eNOTge9trYqY1c7dRElPJjND7NQPHFY/Uwe8MhKqV3+THu0qoITC5Ubvr65M+SBRyY9IRkyxkWx4ByoQCQ4HLuIxAiOH45oNnbSxxDcNpUsNLQHddigQUQ6jSzs1QY+tUrEAumW2W6lGJRwA8qg== wu@navi.local"

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

# get new ports
echo
echo "...Fetching updates to ports tree..."
portsnap --interactive fetch extract || exit 1
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

#echo
#echo "#############################################################################"
#echo "fixing broken freebsd package provider"
#cp /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb.wu
#sed -i.bak "s|package_uri.to_s|package_uri.to_s.gsub\!( \/\\\%2F\/, '' )|" /usr/local/lib/ruby/site_ruby/1.9/puppet/provider/package/freebsd.rb

echo
echo "#############################################################################"
echo "Creating pkg.conf"
cp /usr/local/etc/pkg.conf.sample /usr/local/etc/pkg.conf


#echo
#echo "#############################################################################"
#echo "installing portupgrade for puppet port management..."
#cd /usr/ports/ports-mgmt/portupgrade || exit 1
#make -DBATCH install clean || exit 1

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
echo "#############################################################################"
echo "Setting up ssh key"
mkdir /home/wu/.ssh
echo "$pubkey" >> /home/wu/.ssh/authorized_keys2
chown -R wu:wu /home/wu/.ssh
chmod -R go-rwx /home/wu/.ssh

echo
echo "#############################################################################"
echo "Setting up sudoers"


cd /usr/ports/security/sudo || exit 1
make -DBATCH install clean || exit 1

echo "
root ALL=(ALL) ALL
wu ALL=(ALL) ALL
" > /usr/local/etc/sudoers
chmod 440 /usr/local/etc/sudoers

echo
echo
echo "#############################################################################"
echo "Bootstrapped successfully"
echo

echo "Connecting to puppet to finish configuration...\n\n";
echo puppet agent -v --server puppetmaster.subaudi.net --waitforcert 60 --test
puppet agent -v --server puppetmaster.subaudi.net --waitforcert 60 --test


echo
echo "Puppet run complete..."
echo
echo puppet agent -v --server puppetmaster.subaudi.net --waitforcert 60 --test
