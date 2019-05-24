# Postgres Deploy Docker

The goal of this repository is to produce a reference deployment of
[Postgres](https://www.postgresql.org/) for a few users who need, intially,
identical databases.  The main use case targeted is **small to medium groups of
trusted users working on a single server** who need a postgres database.

## Design goal of this reference deployment

Create a postgres reference deployment that is simple yet functional:

* [x] Use a single server
* [x] Configure using Ansible scripts.
* [x] Docker
* [x] Authenticate using username / pass
* [ ] Authenticate using LDAP

## Prerequisites

To *deploy* this postgres reference deployment, you should have:

- An empty CentOS server running the latest stable release
- A valid DNS name
- Passwordless SSH to your CentOS server
- Provide data & sql scripts to create the initial template database

For *administration* of the server, you should also:

- Specify the users of the database with passwords in a JSON file

## Adding a new server

### Inventory File

Ansible has a concept of "hosts" which are uniquely identified by a FQDN, e.g.
www.example.com.  To add a new host, you'll need to create a few new files.
Most importantly, you'll need to create an inventory file (INI format) that
looks something like this:  

```
# The `hosts` inventory file lists the servers managed by Ansible

# This provides an inventory of host servers used for Postgres
# Edit the fqdn (fully qualified domain name) for your hub server
# For example:
#
# [postgres_hosts]
# www.example.com

[postgres_hosts]
hostname.example
```

It's important that you put your hosts under the `[postgres_hosts]` header.  If
you don't have SSH access through your FQDN yet, you can add the IP of your
server like so:

```
www.example.com ansible_host=10.10.10.10
```

### Host Variables

The inventory file indicates which servers you'd like to deploy to.  Host
variables control anything that varies in between those servers.  For example,
you might want to split your users onto 4 different servers, you can provide 4
different host files that can control this.

At this point only username / password authentication is set up.  You'll need
to provide a list of objects with username and password fields set:

```
# File: host_vars/www.example.com

pg_auth:
  # This option allows you to provide a list of objects with username and password fields set.
  users:
    - username: bob
      password: 1234
    - username: alice
      password: 5678
```

Alternatively, you can provide this in a JSON file and use the Ansible lookup
utility:

```
# File: host_vars/www.example.com

# Only necessary if planning on reading user information from a JSON file.
pg_users_file: "host_vars/{{ inventory_hostname }}-postgres-users.json"

pg_auth:
  # This option allows you to provide a list of objects with username and password fields set.
  users: "{{ lookup('file', pg_users_file) | from_json }}"
```

## Adding your own data

This deployment creates a template database (potentially with multiple tables)
and then copies that database over to each user that gets created.  To create 
this database, simply put a
