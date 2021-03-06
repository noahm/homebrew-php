require 'formula'
require File.expand_path("../../Requirements/php-meta-requirement", Pathname.new(__FILE__).realpath)
require File.expand_path("../../Requirements/phar-requirement", Pathname.new(__FILE__).realpath)
require File.expand_path("../../Requirements/phar-building-requirement", Pathname.new(__FILE__).realpath)

class PhpCsFixer < Formula
  homepage 'http://cs.sensiolabs.org'
  url 'https://github.com/fabpot/PHP-CS-Fixer/archive/v0.2.0.tar.gz'
  sha1 'b656560c28b31da179b1a4a53a23b9e356d582ff'
  head 'https://github.com/fabpot/PHP-CS-Fixer.git'

  def self.init
    depends_on PhpMetaRequirement
    depends_on PharRequirement
    depends_on PharBuildingRequirement
    depends_on "composer"
    depends_on "php53" if Formula.factory("php53").linked_keg.exist?
    depends_on "php54" if Formula.factory("php54").linked_keg.exist?
    depends_on "php55" if Formula.factory("php55").linked_keg.exist?
 end

  init

  def install
    File.open("genphar.php", 'w') {|f| f.write(phar_stub) }

    cmd = [
      "mkdir -p src",
      "rsync -a --exclude 'src' . src/",
      "cd src && /usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off  #{Formula.factory('composer').libexec}/composer.phar install",
      "cd src && sed -i '' '1d' php-cs-fixer",
      "php -f genphar.php",
    ].each { |c| `#{c}` }

    libexec.install "php-cs-fixer.phar"
    sh = libexec + "php-cs-fixer"
    sh.write("#!/bin/sh\n\n/usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off #{libexec}/php-cs-fixer.phar $*")
    chmod 0755, sh
    bin.install_symlink sh
  end

  def test
    system 'php-cs-fixer --version'
  end

  def phar_stub
    <<-EOS.undent
      <?php
      $stub =<<<STUB
      <?php
      /** This was auto-built from source (https://github.com/fabpot/PHP-CS-Fixer) via Homebrew **/
      Phar::mapPhar('php-cs-fixer.phar'); require 'phar://php-cs-fixer.phar/php-cs-fixer'; __HALT_COMPILER(); ?>";
      STUB;
      $phar = new Phar('php-cs-fixer.phar');
      $phar->setAlias('php-cs-fixer.phar');
      $phar->buildFromDirectory('src');
      $phar->setStub($stub);
    EOS
  end

  def caveats; <<-EOS.undent
    Verify your installation by running:
      "php-cs-fixer --version".

    You can read more about php-cs-fixer by running:
      "brew home php-cs-fixer".
    EOS
  end
end
