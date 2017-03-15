name             "php5-mysql"
maintainer       "Yuriy Chernyshev"
maintainer_email "yuriy.chernyshev@gmail.com"
license          "MIT license"
description      "Installs/Configures the php5-mysql module for PHP"
version          "0.1.0"

supports 'ubuntu'
supports 'debian'

depends "php"

recipe 'php5-mysql', 'Installs/Configures the php5-mysql module for PHP'
