FROM ubuntu:14.04

MAINTAINER Magenete Systems OÜ <magenete.systems@gmail.com"

RUN apt-get -yqq update && apt-get -yqq upgrade
RUN apt-get install -y nginx
RUN apt-get autoclean -qq && apt-get autoremove -qq

EXPOSE 80
