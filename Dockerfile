FROM byscontrol/tinc:1.1pre14
MAINTAINER ByS Control "info@bys-control.com.ar"

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
curl -sSL https://get.rvm.io | bash && \
echo 'source /etc/profile.d/rvm.sh' >> /root/.bashrc

# Install Ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2 && gem install bundler --no-ri --no-rdoc"
