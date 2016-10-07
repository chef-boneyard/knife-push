# Knife Push

[![Gem Version](https://badge.fury.io/rb/knife-push.svg)](https://badge.fury.io/rb/knife-push) [![Build Status](https://travis-ci.org/chef/knife-push.svg?branch=master)](https://travis-ci.org/chef/knife-push)

The knife push plugin is used by the Chef workstation to interact with the Push API to start jobs, view job status, view job lists, and view node status.

## Requirements

- Chef 12.0 higher
- Ruby 2.2.2 or higher

## Installation:

To build and install the plugin, run:

```shell
    rake install
```

## Configuration:

If push server is running on the same host as the Chef Server, then no reconfiguration is required on the Chef workstation.

## Subcommands:

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag.

### job list

The `job list` subcommand is used to view a list of Push jobs.

#### Syntax $ knife job list

### job start

The `job start` subcommand is used to start a Push job.

#### Syntax

```shell
knife job start (options) COMMAND [NODE, NODE, ...]
```

#### Options

This argument has the following options:

`--timeout TIMEOUT`

The maximum amount of time (in seconds) by which a job must complete, before it will be stopped.

`-q QUORUM --quorum QUORUM`

The minimum number of nodes that match the search criteria, are available, and acknowledge the job request. This can be expressed as a percentage (e.g. 50%) or as an absolute number of nodes (e.g. 145). Default value: 100%

`-b --nowait`

Exit immediately after starting a job instead of waiting for it to complete.

`--with-env ENVIRONMENT`

Accept a json blob of environment variables and use those to set the variables for the client. For example '{"test": "foo"}' will set the push client environment variable "test" to "foo". (Push 2.0 and later)

`--in-dir DIR`

Execute the remote command in the directory DIR. (Push 2.0 and later)

`--file DATAFILE`

Send the file to the client. (Push 2.0 and later)

`--capture`

Capture stdin and stdout for this job. (Push 2.0 and later)

#### Examples

For example, to search for nodes assigned the role "webapp", and where 90% of those nodes must be available, enter:

```shell
knife job start -quorum 90% 'chef-client' --search 'role:webapp'
```

To search for a specific set of nodes (named chico, harpo, groucho, gummo, zeppo), and where 90% of those nodes must be available, enter:

```shell
knife job start --quorum 90% 'chef-client' chico harpo groucho gummo zeppo
```

Use the `knife job start` subcommand to run a job with the following syntax:

```shell
knife job start job_name node_name
```

For example, to run a job named add-glasses against a node named "ricardosalazar", enter the following:

```shell
knife job start add-glasses 'ricardosalazar'
```

### job output

The `job output` command is used to view the output of Push jobs. (Push 2.0 and later). The output capture flag must have been set on job start; see the --capture option.

#### Syntax

```shell
knife job output JOBID
```

#### Examples

```shell
knife job output 26e98ba162fa7ba6fb2793125553c7ae test --channel stdout
```

#### Options

--channel [stderr|stdout]

The output channel to capture.

### job status

The `job status` command is used to view the status of Push jobs.

#### Syntax

```shell
knife job status JOBID
```

#### Examples

For example, to view the status of a job that has the identifier of "235", enter:

```shell
knife job status 235
```

### node status

The `node status` argument is used to identify nodes that Push may interact with.

#### Syntax

```shell
knife node status
```

## Contributing

For information on contributing to this project see <https://github.com/chef/chef/blob/master/CONTRIBUTING.md>


## License

**Author:** John Keiser([jkeiser@chef.io](mailto:jkeiser@chef.io))

**Copyright:** Copyright 2008-2016, Chef Software, Inc.

**License:** Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
