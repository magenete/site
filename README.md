magenete site
=========

[![Build Status](https://travis-ci.org/magenete/site.png)](https://travis-ci.org/magenete/site)

The site of Magenete Systems OÜ.


Installation
------------

Our latest stable is always available on Gem.

    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable

    git clone https://github.com/magenete/site

    rvm install $(cat ./.ruby-version)
    rvm use $(cat ./.ruby-version)

    gem install bundler
    bundle install


Running
------------

    bundle exec rackup config.ru

or

    bundle exec ruby config.ru


License
-------

Copyright (c) 2015 Magenete Systems OÜ. All rights reserved.
