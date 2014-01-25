#!/bin/bash

rdate_server="nist1-la.ustiming.org"

echo
echo updating dpkg...
sudo apt-get update                                       || exit 1

echo
echo installing rdate...
sudo apt-get install rdate                                || exit 1

echo
echo setting time...
sudo rdate -s $rdate_server                               || exit 1

echo
echo installing ruby
sudo apt-get install ruby                                 || exit 1

echo
echo installing puppet
sudo gem install --no-ri --no-rdoc --version 3.2.1 puppet || exit 1

echo
echo CURRENT DATE: $(date)
echo