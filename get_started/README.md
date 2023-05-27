# Terraform - Getting Started

## Notes

### Deploying Your First Terraform Configuration

1. Block Syntax

```tf
block_type "label" "name_label" {
    key = "value"
    nested_block {
        key = "value"
    }
}
```

- **block_type**: Describes type of object

- **label**: Series of labels that are dependent on the type of block we are working
with

- **name_label**: Provides a way to refer back to the object in the rest of the 
configuration

- **key = "value"**: Arguments to the resource

Below is an example for the block syntax

```tf
resource "aws_instance" "web_server" {
    # This name is what we will see in the AWS console
    name = "web-server" 

    ebs_volume {
        size = 40
    }
}
```

2. Terraform Object Reference `<resource_type>.<name_label>.<attribute>`.
For example, `aws_instance.web_server.name`

### Terraform Workflow

1. init
- Terraform init looks for configuration files inside of the current working 
directory and examines them to see if they need any provider plugins.
- If they do, it will try and download those plugins from the public Terraform 
Registry, unless you specify an alternate location.
- Part of the initialization process is getting a state data back end ready. 
If you don't specify a back end, Terraform will create a state data file in the 
current working directory

2. plan
- Terraform will take a look at your current configuration, the contents of 
your state data, determine the differences between the two, and make a plan to 
update your target environment to match the desired configuration. 
- Terraform will print out the plan for you to look at, and you can verify the 
changes Terraform wants to make.
- You can save a plan and feed it as an input to terraform later.

3. apply
- Assuming you ran terraform plan and saved the changes to a file, Terraform 
will simply execute those changes using the provider plugins. The resources 
will be created or modified in the target environment, and then the state data 
will be updated to reflect the changes.
- If we run terraform plan or apply again without making any changes, 
Terraform will tell us no changes are necessary since the configuration and the 
state data match.

4. destroy
- Destroy everything in the target environment

### Deploying the Base Configuration

#### Plan

1. Initialize our configuration
2. Plan the deployment
3. Apply the plan

#### Prerequisites

1. AWS account
2. AWS access keys

