# docker-riak

This is based on dockerfile and scripts from https://github.com/hectcastro/docker-riak 

The changes for my needs were significant enough to not make it a true fork..

Changes from hectcastro/docker-riak

* enable search

* use leveldb instead of bitcask backend

* enable cluster admin control panel with user and password

* removed dependency on pipeworks

* uses docker native networking with icc enabled (inter container comm)

* riak node names are set up based on ip address -- hackish but works

* the cluster startup scripts uses data mounts from the host into the containers 

* start-cluster and test-cluster takes an optional numeric argument for number of nodes - defaults to 5


### major features retained 

* use of supervisord

* use of ssh

* scripts and makefile


### possible todos

* use link names

## Installation

### standalone (single container)

	docker pull lapax/riak
	docker run -d -t -i \
		-h "riak1" \
		-v /path/to/local/directory:/var/lib/riak \
		-name "riak1" \
		"lapax/riak"
or just
	
	docker run -d -t -i lapax/riak

### Cluster installation
#### Install Docker

If you're running Ubuntu, use the instructions for [installing Docker on
Linux](http://docs.docker.io/en/latest/installation/ubuntulinux/).

If you're not on a Ubuntu host, use [Vagrant](http://www.vagrantup.com) to
spin up a [Ubuntu virtual machine with Docker
installed](http://docs.docker.io/en/latest/installation/vagrant/).

Then, login to the virtual machine:

```bash
$ vagrant ssh
```

#### Install dependencies

Once you're on a Ubuntu machine, install the following dependencies:

```bash
$ sudo apt-get install -y git curl make sshpass
```

#### Clone repository

```bash
$ git clone https://github.com/lapax/dockerfile-riak.git
$ cd docker-riak
$ make
$ make riak-container
```

#### Launch cluster

```bash
$ make start-cluster 3
```

#### Test cluster

```bash
$ make test-cluster 3
```

#### Tear down cluster

```bash
$ make stop-cluster
```

#### Troubleshooting

Spinning up Docker containers consumes memory. If the memory allocated to your
Ubuntu [virtual] machine is not adaquate,  `make start-cluster` will fail with
something like:

```
runtime: panic before malloc heap initialized
fatal error: runtime: cannot allocate heap metadata
```
