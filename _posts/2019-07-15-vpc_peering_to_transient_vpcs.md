---
layout: article
title: "Our journey from VPC peerings to Transient gateway"
date: 2019-07-15 10:02:00
categories: [AWS, cloud computing, cloud architecture, networking]
comments: false
author: puneeth_n
image:
  teaser: 2019_07_15/aws_logo.png
  feature: 2019_07_15/tgw.png
---

We at Comtravo run our services in the cloud with [AWS](https://aws.amazon.com/). All our environments (test and production) are mostly orchestrated by [Terraform](https://www.terraform.io/). Our environments spread across multiple AWS accounts all part of the same organization.

We maintain [VPC](https://aws.amazon.com/vpc/) level isolation between environments. In our acceptance testing and production environments, there exists VPC level isolation between the databases and stateless microservices. In these environments, we use [VPC-peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) to establish connections between our stateless VPC and stateful VPC so that our stateless services can connect to our databases. The VPCs in these environments which contain databases are not terraformed. Furthermore, all our microservices are dockerized and run on [AWS ECS](https://aws.amazon.com/ecs/).

## Managing multiple environments

This setup of multiple environments of ours gives us good isolation between environments and makes each environment independent of one another. This also gives us the possibility of creating and destroying test environments on-demand. However, from time to time there might be cases where one might need to perform admin tasks securely on databases or investigate when an EC2 instance is behaving abnormally, in such cases, one might want to login to servers. There are many approaches to achieving this and list below some approaches.

### Deploying everything in the public subnet

When everything is running in the public subnet, the simplest way to connect to EC2 instances is over SSH. For AWS hosted databases, one can [connect to them over SSL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html). If the databases are running inside EC2,one could use the EC2 host as a jump server to connect to the databases. However, this approach is not recommended as it has a huge attack surface and one must run server hardening regularly on all the instances. Multiply the number servers running in each environment and multiply it by the number of different environments, suddenly this approach gets out of hand.

### Using bastion hosts in each environment

One other commonly used approach is the use of [bastion hosts](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html). Bastion servers reduce the attack surface to just the number of bastion hosts and is more secure compared to the previous approach. However, the bastion servers need to be deployed in multiple availability zones and need regular maintenance. Multiplying the number of bastion hosts by the number of environment and all of a sudden this approach also increases the attack surface.

### VPC peerings and Transit VPCs

Transit VPCs are yet another approach which helps in managing lots of independent VPCs and in reducing the attack surface. There are mainly two broad architectures with transit VPCs and which one to use depends upon the use case.

#### Hub and Spoke architecture

If managing the test environments is the only concern, a Hub and Spoke model makes most sense. In this approach, a single VPC called the transit VPC establishes point to point connection to all the VPCS. A user logs in to this transit VPC and could ***potentially*** have access to all the environments. This transit VPC could run a bastion host or a vpn server to which users connect it. This architecture immensely reduces the attack radius and doesn't increase when number of test environments increase. In this architecture the transit VPC is the hub and each VPC peering that it establishes becomes the spoke of the architecture.

<center>
<figure>
  <img style="width: 42.5%; height: 42.5%" src="/images/2019_07_15/hub_and_spoke.png">
  <figcaption><b>Hub and spoke transit VPC</b> <br>(Image taken from https://aws.amazon.com/answers/networking/aws-single-region-multi-vpc-connectivity/)</figcaption>
</figure>
</center>

#### Fully meshed architecture

It is hard to predict the future necessities in a dynamic cloud environment. As the cloud architecture evolves over time due to business requirements, there might be cases where one might be required to provide all environments access to a bunch of shared services. In our case, we have a bunch of 3rd party integrations that are required by all environments. As VPC peerings are not transitive in nature, to establish connections between each environment and the shared VPC, on has to establish a VPC peering connection to every other VPC that it wants to connect it. This fully meshed architecture also reduces the attack radius to a great extent but gets more complicated as the number of environments increase.

<center>
<figure>
  <img style="width: 42.5%; height: 42.5%" src="/images/2019_07_15/full_mesh.png">
  <figcaption><b>Fully meshed transit VPC</b> <br>(Image taken from https://aws.amazon.com/answers/networking/aws-single-region-multi-vpc-connectivity/)</figcaption>
</figure>
</center>

#### Limitations of VPC peerings

There are several limitations with VPC peerings and have been summarized [here](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html#vpc-peering-limitations) and [here](https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html).

### Transit gateways

Ideal setup would be to have a minimal attack reduce and minimal complexity with increased number of environments and AWS [announced](https://aws.amazon.com/blogs/aws/new-use-an-aws-transit-gateway-to-simplify-your-network-architecture/) just that!  A new VPC feature called [Transit gateways (TGW)](https://aws.amazon.com/transit-gateway/).

In this architecture, all VPCs connect to a central *"router"* called a Transit gateway. When all VPCs connect to the transit gateway, they could potentially access each other if their routing rules and security groups allow it. Furthermore, transit gateways can be shared across multiple accounts within the same organization. So it really doesn't matter where in which accoun or accounts the VPCs are. This in my opinion is one of the coolest features AWS recently released. Resources from one AWS account can be shared across other accounts through a new AWS service called [Resource Access Manager (RAM)](https://aws.amazon.com/ram/).

In our case, we have the transit gateway in our master account and is shared with our AWS accounts for test and production environments. Once shared, each sub-account can see the shared resource. All they have to do next is to attach to this transit gateway and adjust the routing rules accordingly.

One very important thing in the VPC peering architecture or transit gateway architecture is 
that, all VPCs should have unique CIDRs.

 
**Creating Transit gateways:**

Here is some code snippet on how to create transit gateways in Terraform.

`>> terraform workspace select master`


```hcl
resource "aws_ec2_transit_gateway" "core" {
  description = "core transit gateway"
  
  tags = {
    Environment = "core-infra"
  }
}
```

Once the transit gateway is created, It can be shared via RAM within your AWS organization.


```hcl
resource "aws_ram_resource_share" "core-tgw" {
  name                      = "core-tgw"
  allow_external_principals = false

  tags = {
    Environment = "core-infra"
  }
}

resource "aws_ram_resource_association" "core-tgw" {
  resource_arn       = "${aws_ec2_transit_gateway.core.arn}"
  resource_share_arn = "${aws_ram_resource_share.core-tgw.arn}"
}

resource "aws_ram_principal_association" "comtravo" {
  principal          = "${aws_organizations_organization.comtravo.arn}"
  resource_share_arn = "${aws_ram_resource_share.core-tgw.arn}"
}
``` 

The above Terraform configuration is part of our Master account's terraform configuration. (terraform workspace: master)

Once the core infra has been established, VPCs can now attach to the transit gateway. Let's go ahead and create a new VPC.

`>> terraform workspace select infra`


```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "nat" {
  count = 1
  vpc   = true

  tags {
    Name        = "${terraform.workspace}-nat-gateway-eip-${count.index}"
    environment = "${terraform.workspace}"
  }
}

# Infrastructure VPC
module "infra_vpc" {
  source = "github.com/comtravo/terraform-aws-vpc?ref=2.1.0"

  enable             = 1
  vpc_name           = "${terraform.workspace}"
  cidr               = "${var.ct_vpc_cidr}"
  availability_zones = "${data.aws_availability_zones.available.names}"
  subdomain          = "${terraform.workspace}.comtravo.com"
  depends_id         = ""

  private_subnets {
    number_of_subnets = 3
    newbits           = 4
    netnum_offset     = 0
  }

  public_subnets {
    number_of_subnets = 3
    newbits           = 4
    netnum_offset     = 8
  }

  external_elastic_ips = ["${aws_eip.nat.*.id}"]

  tags {
    environment = "${terraform.workspace}"
  }
}
```


The above VPC can be then attached to our core TGW. Below is a full bblown snippet on how one cann connect the `infra` VPC to the `core-tgw`.


```hcl
resource "aws_route" "private_route_table_tgw_attachment" {
  count                  = "${length(module.infra_vpc.vpc_private_routing_table_id)}"
  route_table_id         = "${element(module.infra_vpc.vpc_private_routing_table_id, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

resource "aws_route" "public_route_table_tgw_attachment" {
  route_table_id         = "${module.infra_vpc.vpc_public_routing_table_id}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

resource "aws_route" "private_route_table_tgw_attachment_prod_state" {
  count                  = "${length(module.infra_vpc.vpc_private_routing_table_id)}"
  route_table_id         = "${element(module.infra_vpc.vpc_private_routing_table_id, count.index)}"
  destination_cidr_block = "172.31.0.0/16"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

resource "aws_route" "public_route_table_tgw_attachment_prod_state" {
  route_table_id         = "${module.infra_vpc.vpc_public_routing_table_id}"
  destination_cidr_block = "172.31.0.0/16"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

resource "aws_route" "private_route_table_tgw_attachment_qa_state" {
  count                  = "${length(module.infra_vpc.vpc_private_routing_table_id)}"
  route_table_id         = "${element(module.infra_vpc.vpc_private_routing_table_id, count.index)}"
  destination_cidr_block = "172.30.0.0/16"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

resource "aws_route" "public_route_table_tgw_attachment_qa_state" {
  route_table_id         = "${module.infra_vpc.vpc_public_routing_table_id}"
  destination_cidr_block = "172.30.0.0/16"
  transit_gateway_id     = "${lookup(var.ct_transit_gateway, "transit_gateway_id")}"
}

```

With the above configuration, anything running in the `infra` VPC can *potentially* access anything in the CIDR ranges `172.30.0.0/16 172.31.0.0/16 10.0.0.0/8`.

We migrated completely to transit gateways and our architecture has been simplified immensely and looks approximately as below.

<center>
<figure>
  <img style="width: 100.0%; height: 100.0%" src="/images/2019_07_15/current_setup.png">
  <figcaption><b>Current VPC architecture at Comtravo</b> <br></figcaption>
</figure>
</center>


In the next blog post, we look into how to leverage transit gateways and client ot site VPN endpoints to have a centralized access management to the cloud.