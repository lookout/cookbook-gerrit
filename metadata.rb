name             "gerrit"
maintainer       "Steffen Gebert"
maintainer_email "steffen.gebert@typo3.org"
license          "Apache 2.0"
description      "Installs/Configures gerrit"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.4.5"

depends "apache2", "= 2.0.0"
depends "database", "= 1.3.12"
depends "mysql", "= 1.3.0"
depends "java", "= 1.29.0"
depends "git", "= 0.9.0"
