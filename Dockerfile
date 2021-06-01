FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME="user"
ARG USER_PASSWORD="P@ssword1"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD

# Install useful applications and libraries
RUN apt-get update \
&& apt-get install -y  zsh git sudo nano curl wget neovim jq htop jed \
links lynx tmux most python3-pip python3.9-dev tree openjdk-11-jdk \ 
ruby-dev libssl-dev build-essential default-jdk pinentry-curses scdaemon \
gnupg2 time \ 
&& curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin \
&& wget -q -O /tmp/bat.deb "https://github.com/sharkdp/bat/releases/download/v0.18.1/bat_0.18.1_amd64.deb" \
&& wget -q -O /tmp/lsd.deb "https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb" \
&& wget -q -O /tmp/xidel.deb "https://github.com/benibela/xidel/releases/download/Xidel_0.9.8/xidel_0.9.8-1_amd64.deb" \
&& dpkg -i /tmp/*.deb \
&& wget -q -O /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64" \
&& chmod +x /usr/bin/yq

RUN wget -q -O /tmp/gradle.zip "https://services.gradle.org/distributions/gradle-7.0.2-all.zip" \
&& mkdir /opt/gradle \
&& unzip -d /opt/gradle /tmp/gradle.zip \
&& ln -s /opt/gradle/gradle-7.0.2/bin/gradle /usr/bin/gradle

RUN wget -q -O /tmp/maven.zip "https://www.mirrorservice.org/sites/ftp.apache.org/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.zip" \ 
&& mkdir /opt/maven \
&& unzip -d /opt/maven /tmp/maven.zip \
&& ln -s /opt/maven/apache-maven-3.8.1/bin/mvn /usr/bin/mvn \
&& ln -s /opt/maven/apache-maven-3.8.1/bin/mvnyjp /usr/bin/mvnyjp

# add a user (--disabled-password: the user won't be able to use the account until the password is set)
RUN adduser --quiet --disabled-password --shell /bin/zsh --home /home/$USER_NAME --gecos "User" $USER_NAME \
# update the password
&& echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME

USER $USER_NAME
WORKDIR /home/$USER_NAME
ENV USER $USER_NAME
ENV HOME /home/$USER_NAME

RUN mkdir -p /home/$USER_NAME/Documents \
/home/$USER_NAME/Development \
/home/$USER_NAME/Public \
/home/$USER_NAME/Downloads \
/home/$USER_NAME/Desktop \
/home/$USER_NAME/Music \
/home/$USER_NAME/Pictures \
/home/$USER_NAME/Movies

# Install RBEnv, Ruby 3.0.1 and JEnv
RUN git clone https://github.com/rbenv/rbenv.git /home/$USER_NAME/.rbenv \
&& cd /home/$USER_NAME/.rbenv && src/configure && make -C src \
&& mkdir -p /home/$USER_NAME/.rbenv/plugins \
&& git clone -q https://github.com/rbenv/ruby-build.git /home/$USER_NAME/.rbenv/plugins/ruby-build \
&& git clone $GIT_QUIET https://github.com/gcuisinier/jenv.git /home/$USER_NAME/.jenv \
&& mkdir /home/$USER_NAME/.jenv/versions \
&& /home/$USER_NAME/.jenv/bin/jenv add /usr/lib/jvm/java-11-openjdk-amd64 \
&& /home/$USER_NAME/.rbenv/bin/rbenv install 3.0.1 \
&& /home/$USER_NAME/.rbenv/bin/rbenv global 3.0.1

# Get the dot files and run setup script
RUN git clone https://github.com/j-maynard/terminal-config.git /home/$USER_NAME/.term-config \
&& /home/$USER_NAME/.term-config/scripts/config-setup.sh -d $USER_NAME -c /home/$USER_NAME/.term-config \
&& /home/$USER_NAME/.fzf/install --all \
&& mkdir /home/$USER_NAME/.ssh \
&& mkdir /home/$USER_NAME/.gnupg

ENV TERM=xterm-256color
CMD ["/usr/bin/zsh"]
