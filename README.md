#Terraform @ TravCorp

###What is Terraform?

Have a look at the product site: https://www.terraform.io/ the creators can pitch their product better than I can.

###What do we use if for?

Currently Terraform is used for maintaining the data centre proxy (or DCProxy) VPC in our various AWS accounts, for more information on  this VPC and it's purpose please take a look at the documentation in this repository - https://github.com/travcorp/general-docs.git . It is also used for standardizing and maintaining the AWS CloudTrail configuration in our AWS accounts.

###How does it work?

Below is an overview of how Terraform has been implemented:

![Terraform Overview](images/terraform_overview.png "Terraform Overview")

There five main components to this setup:

1. **GitHub** - for maintaining the Terraform source code and scripts
2. **Artifactory** - for storing the Terraform state files away from the source code
3. **Amazon Web Services** - for building our infrastructure
4. **wrapper.sh script** - for simplifying and automating Terraform
5. **credentials.sh script** - for setting up AWS and Artifactory secrets

We will go into more detail on the these below.

###Getting started

Firstly go and download Terraform for your OS here https://www.terraform.io/downloads.html and unzip it to a directory on your machine and make sure that this directory's path is included on your `%PATH%` environment variable or if you are working on a proper operating system your `$PATH` environment variable.

Since the `credentials.sh` and `wrapper.sh` scripts are written in good old fashioned Bash you will need to install Cygwin if you are working on the Windows platform. It can be downloaded here https://cygwin.com/install.html .

Once you have installed the above software you will need to clone this repository - `git clone https://github.com/travcorp/terraform.git`

Now you need to set up the `credentials.sh` file with the Artifactory Terraform state file repository's details and your AWS API keys for the environments you are going to be working on. **If you do not already have the necessary secrets please speak to your line manager as they have access to them.** The script is very easy to understand so there is no need to go into anymore detail on this. **Just remember not to push your you changes to this file to Github.** You can run the following command on your local Terraform repository to ensure that any changes you make to this file are ignored `git update-index --assume-unchanged credentials.sh`. It would good if secret management was refactored at some point so that the secrets in `credentials.sh` are available to Terraform without this needing this script.  Constantly making sure you are not pushing secrets to GitHub is a pain in the ass.

Now you can start working with Terraform.

###Working with Terraform

The `wrapper.sh` script is where all the magic happens and serves the following purposes:

1. Wrapping up the often verbose Terraform commands and syntax
2. Allowing us to have individual state files for each AWS environment and Terraform configuration combination by using Artifactory as a backend for storing them

Here is the syntax of 'wrapper.sh' and the Terraform commands it supports:

####Basic wrapper.sh syntax

` ./wrapper.sh [Terraform command] [Terraform configuration] [Environment]`

This script should always be run the root of the repository so that you can pass Terraform configuration directories as the second parameter.

For example if you wanted to apply the changes you have made within the dcproxy configuration to the AWS dev environment you would execute the following command:

` ./wrapper.sh apply dcproxy dev`

####Terraform commands supported by wrapper.sh

**apply**

Applies configuration changes to the target environment. Find out more here https://www.terraform.io/docs/commands/apply.html

` ./wrapper.sh apply dcproxy dev` - Applies the changes contained in the dcproxy configuration to the dev environment.

**destroy**

Destroys the managed infrastructure in the target environment. Find out more here https://www.terraform.io/docs/commands/destroy.html

` ./wrapper.sh destroy cloudtrail qa` - Destroys the infrastructure defined in the cloudtrail configuration in the QA environment.

**plan**

Generates an execution plan of the changes that will be made to the target environment when the apply command is issued. Find out more here https://www.terraform.io/docs/commands/plan.html

` ./wrapper.sh plan dcproxy prod` - Generates an execution plan for making the changes contained in the dcproxy configuration to the Production environment.

**get**

Updates the Terraform modules for given configuration. Find out more here https://www.terraform.io/docs/commands/get.html

` ./wrapper.sh get dcproxy dev` - Updates the Terraform modules for the dcproxy configuration while working on the dev environment.

**taint**

Marks a resource as tainted so that it destroyed the next time the appy command is issued. Find out more here https://www.terraform.io/docs/commands/taint.html

` ./wrapper.sh taint dcproxy dev vpc` - taints all the resources in the VPC module for the dev environment.

` ./wrapper.sh taint dcproxy dev vpc internet_gateway` - taints the internet_gateway resource in the VPC module for the dev. environment

**output**

Displays all the output variables for the specified target configuration and environment. Find out more here https://www.terraform.io/docs/commands/output.html

` ./wrapper.sh output cloudtrail prod` - Outputs the details of the cloudtrail configuration in the Production environment.

**show**

Prints out a human readable version of the state file for the target environment and configuration. Find out more here https://www.terraform.io/docs/commands/show.html

` ./wrapper.sh show dcproxy uat` - Prints out the state file for the dcproxy configuration in the UAT environment.

####Hacking on the codez

This is documented extensively on the Terraform website however I will highlight sections in the documentation which have been used extensively in this implementation, these are in no particular order:

https://www.terraform.io/docs/state/remote/artifactory.html

https://www.terraform.io/docs/modules/index.html

https://www.terraform.io/docs/configuration/outputs.html

https://www.terraform.io/docs/configuration/interpolation.html

https://www.terraform.io/docs/providers/aws/index.html

https://www.terraform.io/docs/configuration/syntax.html

The root of the Terraform documentation is here https://www.terraform.io/docs/index.html
