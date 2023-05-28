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

#### Steps

1. Initialize our configuration
2. Plan the deployment
3. Apply the plan

#### Prerequisites

1. AWS account
2. AWS access keys

### Using Input Variables and Outputs

1. Working with data inside terraform
    1. **Input variables**
    - They are also known as *variables*
    - Values are supplied when terraform is executed


    2. **Local Values**  
    - They are also known as *locals*
    - They are computed values based on internal references and input variables


    3. **Output Values**
    - They are defined in the configuration 
    - The value of each output will depend on what it references inside the 
    configuration
    - Just like locals, the output value can be constructed from one or more 
    elements. 

2. Input variable syntax:

```hcl
variable "name_label" {}
variable "name_label" {
    type = value
    description = "value"
    default = "value"

    # won't show value in logs or terminal output
    sensitive = true | false }
}
```

example:
```
variable "billing_tag" {}

variable "aws_region" {
    type = string
    description = "Region to use for AWS resources"
    default = "us-east-1"
    sensitive = false
}

variable "aws_instance_sizes" {
    type = map(string)
    description = "Instance sizes to use for AWS EC2"
    default = {
        small = "t2.micro"
        medium = "t2.small"
        large = "t2.large"
    }
}
```

3. Terraform variable reference

```
var.<name_label>
```

example:

```
var.aws_region
```

4. [Terraform Data types](https://developer.hashicorp.com/terraform/language/expressions/type-constraints)

    1. Primitive
    - string
    - number
    - boolean

    2. Collection
    - list
    - set
    - map

    3. Structural
    - tuple
    - object

example:

```
# List
[1, 2, 3, 4]
["us-east-1", "us-east-2", "us.west-1", "us-west-2"]
[1, "us-east-2", true] # INVALID LIST

# Map
{
    small = "t2.micro"
    medium = "t2.small"
    large = "t2.large"
}
```

5. Referencing Collection Values

```
# LIST
var.<name_label>[<element_number>]

# MAP 
var.<name_label>.<key_name> 
var.<name_label>["<key_name>"]
```

example:

```
var.aws_regions[0]

var.aws_instance_sizes.small 
var.aws_instance_sizes["small"]
```

6. Locals Syntax

```hcl
locals {
    key = value
}
```

example:

```
locals {
    instance_prefix = "globo"
    common_tags = {
        company = "Globomantics"
        project = var.project
        billing = var.billing_code
    }
}
```

7. Terraform Locals Reference

```
local.<name_label>
```

example:

```
local.instance_prefix
local.common_tags.company
```

8. Output Syntax

```hcl
output "name_label" {
    value = output_value
    description = "Description of output"
    sensitive = true | false
}
```

example: 

```
output "public_dns_hostname" {
    value = aws_instance.web_server.public_dns
    description = "Public DNS hostname web server"
}
```

9. Validating Configuration

    1. `validate` is the command provided by terraform to validate 
    the configuration
    2. You will need to run `init` command before you run the `validate`
    command because it's checking the syntax and arguments of the resources
    in the providers and needs the provider plugins to do so.
    3. When you run `validate`, it will check your syntax and logic to make 
    sure everything looks good
    4. It doesn't check the current state of your deployments it just checks
    the contents of your configuration
    5. It does not guarantee that the updated deployments will be successful. 
    The configuration might be corrent but the deployment can fail for number
    of reasons such as incorrent instance size, overlapping address space,
    insufficient capacity, etc.

10. Supply Variable Values (Ordered in decending order of precedence)
    1. Environment variable (TF_VAR_<NAME>)
    2. terraform.tfvars or terraform.tfvars.json
    3. .auto.tfvars or .auto.tfvars.json
    4. -var-file <name>=<path>
    5. -var <name>=<value>
    6. Command line prompt
    7. Default Value

11. Formatting Configuration (`terraform fmt`)

12. Difference between locals and variables

| Locals | Variables | 
|--------|-----------|
|Local values allow you to define intermediate computed values that can be stored or reuse to make the configuration more readable, concise, and provide a single source of truth |The variables allow you to define dynamic values that can allow customization and flexibility in your Terraform deployments     |
|Locals are like variables in a program|Variables are like input to a program|
