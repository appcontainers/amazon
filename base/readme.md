## Amazon Linux Base Minimal Install - 138 MB - Updated 03/25/2017 (tags: latest, 2016.09)

***This container is built from amazonlinux:latest, (292 MB Before Flatification)***

># Installation Steps:

### Install the Epel Repository

```bash
yum install -y epel-release
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
```

### Install the Remi Repository

```bash
cd /etc/yum.repos.d/;
curl -O http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
rpm -Uvh remi-release-6*.rpm;
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
rm -fr *.rpm
```

### Modify Remi Repo to enable remi base and PHP 5.5

```bash
sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo;
sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
```

### Update the OS and install required packages

```bash
yum clean all;
yum -y update;
yum -y install findutils;
```

### Cleanup

***Remove the contents of /var/cache/ after a yum update or yum install will save about 150MB from the image size***

```bash
yum clean all
rm -f /etc/yum.repos.d/*.rpm; rm -fr /var/cache/*
```

### Cleanup Locales

```bash
for x in `ls /usr/share/locale | grep -v -i en | grep -v -i local`;do rm -fr /usr/share/locale/$x; done && \
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done && \
rm -fr /usr/share/locale/ca* /usr/share/locale/den /usr/share/locale/men /usr/share/locale/wen /usr/share/locale/zen
```

```bash
cd /usr/lib/locale;
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive;
mv -f locale-archive locale-archive.tmpl;
build-locale-archive
```

### Set the default Timezone to EST

```bash
cp /etc/localtime /root/old.timezone && \
rm -f /etc/localtime && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
```

### Remove Man Pages and Docs to preserve Space

```bash
rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/*;
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*
```

### Set the Terminal CLI Prompt

***Copy the included Terminal CLI Color Scheme file to /etc/profile.d so that the terminal color will be included in all child images***

```bash
#!/bin/bash
if [ "$PS1" ]; then
    set_prompt () {
    Last_Command=$?
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    YellowBack='\[\e[01;43m\]'
    Green='\[\e[01;32m\]'
    Yellow='\[\e[01;33m\]'
    Black='\[\e[01;30m\]'
    Reset='\[\e[00m\]'
    FancyX=':('
    Checkmark=':)'

    # If it was successful, print a green check mark. Otherwise, print a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1="$Green$Checkmark "
    else
        PS1="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Black $YellowBack $TERMTAG $Reset $Red \\u@\\h"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
    fi
    # Print the working directory and prompt marker in blue, and reset the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
fi
```

### Prevent the .bashrc from being executed via SSH or SCP sessions

```bash
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc
```

### Set Dockerfile Runtime command

***Default command to run when lauched via docker run***

```bash
CMD /bin/bash
```
&nbsp;

># Building the image from the Dockerfile:

```bash
docker build -t build/amazon .
```
&nbsp;

># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported.

&nbsp;

># Flatten the Image

***Run the build container***

```bash
docker run -it -d \
--name amazon \
build/amazon \
/bin/bash
```

***The run statement should start a detached container, however if you are attached, detach from the container*** 

`CTL P` + `CTL Q`


***Export and Re-import the Container***

__Note that because we started the build container with the name of amazon, we will use that in the export statement instead of the container ID.__

```bash
docker export amazon | docker import - appcontainers/amazon:latest
```

***Verify***

Issuing a `docker images` should now show a newly saved appcontainers/amazon image, which can be pushed to the docker hub.

***Run the container***

```bash
docker run -it -d appcontainers/amazon
```

&nbsp;

># Dockerfile Change-log:

    03/25/2017 - Rebuild with split of base raw and base ansible
    11/28/2016 - Initial build including vim, python, pip, and ansible
