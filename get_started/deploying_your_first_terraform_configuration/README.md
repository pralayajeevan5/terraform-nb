# Deploying Your First Terraform Configuration

## Notes

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
