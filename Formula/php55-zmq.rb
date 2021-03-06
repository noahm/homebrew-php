require File.join(File.dirname(__FILE__), 'abstract-php-extension')

class Php55Zmq < AbstractPhp55Extension
  init
  homepage 'http://php.zero.mq/'
  url 'https://github.com/mkoppanen/php-zmq/archive/1.1.1.tar.gz'
  sha1 '7c90908d80f13c06f3704efa19b96fc78fa7770f'
  head 'https://github.com/mkoppanen/php-zmq.git'

  depends_on 'pkg-config' => :build
  depends_on 'zeromq'  

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig
    system "make"
    prefix.install "modules/zmq.so"
    write_config_file unless build.include? "without-config-file"
  end
end
