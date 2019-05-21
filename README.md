# Postgres Deploy Teaching Docker
The goal of this repository is to produce a reference deployment of [Postgres]() for courses that require .

The main use case targeted is **small to medium groups of trusted users
working on a single server** who need a postgres database.

## Design goal of this reference deployment

Create a postgres reference deployment that is simple yet functional:

[x] Use a single server.
[x] Configure using Ansible scripts.
[x] Uses Docker to serve the hub and user servers

## Prerequisites

To *deploy* this postgres reference deployment, you should have:

- An empty CentOS server running the latest stable release
- A valid DNS name

For *administration* of the server, you should also:

- Specify the admin users of the database.
- Specify the users of the database.
- Provide scripts to create a template database that user DBs are based off of.
- Allow SSH key based access to server and add the public SSH keys of GitHub
  users who need to be able to SSH to the server as `root` for administration.

For *managing users and services* on the server, you will:

- [Authenticate](https://www.postgresql.org/docs/9/auth-methods.html) and manage users with either:
    * username / password
    * LDAP
- run postgres using docker
