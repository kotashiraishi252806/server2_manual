FROM php:7.4-apache

# 必要なPHP拡張をインストール
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# inotify拡張をインストール
# Apacheの設定に index.php を追加
RUN echo 'DirectoryIndex index.php index.html' >> /etc/apache2/apache2.conf