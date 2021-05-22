# Custom deb build CI pipeline

### Purpose

Provide fast iteration building custom deb package from source code locally


### Prerequisite

 - Setup local Concourse
 - Setup local Artifactory

Setup local Concourse
```
https://github.com/concourse/concourse-docker

# git clone git@github.com:concourse/concourse-docker.git
# cd ~/concourse-docker
# bash keys/generate
# sed -i .bak "s/version..*/version: '2'/g" docker-compose.yml
# sed -i .bak "s/concourse\/concourse.*/concourse\/concourse:ubuntu/g" docker-compose.yml
# docker-compose up -d
# docker-compose logs -f

http://localhost:8080
test/test

# docker-compose down --rmi all
```

Setup local Artifactory

```
https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-DockerInstallation
https://medium.com/concourse-ci/getting-started-with-concourse-ci-on-macos-fb3a49a8e6b4
https://concoursetutorial.com

# mkdir ~/jfog
# JFROG_HOME=~/jfog
# id $USER
uid=501(yen) gid=20(staff)

# mkdir -p $JFROG_HOME/artifactory/var/etc/
# cd $JFROG_HOME/artifactory/var/etc/
# touch ./system.yaml
# chown -R 501:20 $JFROG_HOME/artifactory/var
# chmod -R 777 $JFROG_HOME/artifactory/var
# docker run --name artifactory -v ~/jfog/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest

http://localhost:8082
admin/password
```

docker ps
```
$ docker ps
CONTAINER ID        IMAGE                                                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
c5cec32fe36f        releases-docker.jfrog.io/jfrog/artifactory-oss:latest   "/entrypoint-artifac…"   21 hours ago        Up 21 hours         0.0.0.0:8081-8082->8081-8082/tcp   artifactory
d6ee636516f4        concourse/concourse:ubuntu                              "dumb-init /usr/loca…"   21 hours ago        Up 21 hours                                            concoursedocker_worker_1
7ec66dae4cb2        concourse/concourse:ubuntu                              "dumb-init /usr/loca…"   21 hours ago        Up 21 hours         0.0.0.0:8080->8080/tcp             concoursedocker_web_1
018e43fcaed6        postgres                                                "docker-entrypoint.s…"   21 hours ago        Up 21 hours         5432/tcp                           concoursedocker_db_1
```




### Usage
---
Credentials in ~/.ssh/credentials.yml

```
$ cat ~/.ssh/credentials.yml
local_artifactory_ip: $YOUR_LAPTOP_IP
artifactory_user: $YOUR_USERNAME
artifactory_password: $YOUR_PASSWORD
publishing-outputs-private-key: |-
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
    ---YOUR PRIVATE KEY TO GITHUB---
    XnVyfo4zYykCcAAAAaeWVuQHllbnMtTWFjQm9vay1Qcm8ubG9jYWwB
    -----END OPENSSH PRIVATE KEY-----
```

How to trigger a build
```
# git clone $TARGET_SOURCE_CODE_REPO
# brew install fly
# fly --target example login --team-name main --concourse-url http://localhost:8080
# cd ~/$TARGET_SOURCE_CODE_REPO
# bash run.sh
```

How to retrieve custom deb from Artifactory
```
https://jfrog.com/getcli/

Upload file
$ jfrog rt u test123 example-repo-local/ --user=$YOUR_USERNAME --password=$YOUR_PASSWORD --url=http://localhost:8082/artifactory
 Log path: /Users/yen/.jfrog/logs/jfrog-cli.2021-02-16.03-05-04.50506.log
{
  "status": "success",
  "totals": {
    "success": 1,
    "failure": 0
  }
}

Check file
$ jfrog rt s example-repo-local/ --user=$YOUR_USERNAME --password=$YOUR_PASSWORD --url=http://localhost:8082/artifactory
[Info] Searching artifacts...
[Info] Found 1 artifact.
[
  {
    "path": "ext-release-local/test123",
    "type": "file",
    "created": "2021-02-16T03:57:09.851Z",
    "modified": "2021-02-16T09:05:05.371Z",
    "sha1": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "md5": "d41d8cd98f00b204e9800998ecf8427e"
  }
]

Download file
$ jfrog rt dl "example-repo-local/test123" --user=$YOUR_USERNAME --password=$YOUR_PASSWORD --url=http://localhost:8082/artifactory
 Log path: /Users/yen/.jfrog/logs/jfrog-cli.2021-02-16.15-04-16.10408.log
{
  "status": "success",
  "totals": {
    "success": 1,
    "failure": 0
  }
}
```

Using extract.sh to extract under /tmp
```
$ brew install dpkg
$ bash extract.sh $ARTIFACTORY_USER $ARTIFACTORY_PASSWORD $NEW_BUILD

 Log path: /Users/yen/.jfrog/logs/jfrog-cli.2021-02-25.16-32-57.44768.log
{
  "status": "success",
  "totals": {
    "success": 1,
    "failure": 0
  }
}
Password:
.
├── DEBIAN
│   ├── conffiles
│   ├── control
│   ├── postinst
│   ├── postrm
│   └── prerm
├── etc
│   └── test
│       └── test_agentd.conf
├── lib
│   └── systemd
│       └── system
│           └── test-agent.service
├── usr
│   ├── bin
│   │   ├── yen-test_get-2021-02-25
│   │   └── yen-test_sender-2021-02-25
│   ├── local
│   │   └── share
│   │       └── man
│   │           ├── man1
│   │           │   ├── yen-test_get-2021-02-25.1.gz
│   │           │   └── yen-test_sender-2021-02-25.1.gz
│   │           └── man8
│   │               └── yen-test_agentd-2021-02-25.8.gz
│   ├── sbin
│   │   └── yen-test_agentd-2021-02-25
│   └── share
│       └── doc
│           └── test-agent
│               ├── AUTHORS
│               ├── COPYING
│               ├── ChangeLog
│               ├── INSTALL
│               ├── NEWS
│               ├── README
│               └── README.md
└── test-agent_202102252045-1_amd64.deb

```
