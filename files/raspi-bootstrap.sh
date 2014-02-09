#!/bin/bash

echo
echo updating dpkg...
sudo apt-get update                                       || exit 1

echo
echo installing rdate...
sudo apt-get install rdate                                || exit 1

echo
echo setting time...
echo "before: $(date)"
# http://tf.nist.gov/tf-cgi/servers.cgi
for server in nist1-la.ustiming.org nist-time-server.eoni.com
do
    echo "Attempting to set time from $server..."
    if sudo timeout 15 rdate -s $server
    then
        echo "Success!"
        break
    else
        echo "failed"
    fi
done
echo "after:  $(date)"

echo
echo installing ruby
sudo apt-get install ruby                                 || exit 1

echo
echo installing ruby-dev
echo "Y" | sudo apt-get install ruby-dev                  || exit 1

echo
echo installing puppet
sudo gem install --no-ri --no-rdoc --version 3.2.1 puppet || exit 1

echo
echo installing librarian-puppet
sudo gem install --no-ri --no-rdoc librarian-puppet || exit 1

echo
echo CURRENT DATE: $(date)
echo
