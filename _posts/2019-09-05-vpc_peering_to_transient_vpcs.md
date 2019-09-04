---
layout: article
title: "Our Journey from VPC Peerings to Transit Gateway"
date: 2019-09-05 11:30:00
categories: [AWS, cloud, architecture, networking, security]
comments: false
author: puneeth_n
image:
  teaser: 2019_07_15/aws_logo.png
  feature: 2019_07_15/tgw.png
---

At Comtravo, we run our services in the cloud with [AWS](https://aws.amazon.com/). We run multiple environments each having their own [VPC](https://aws.amazon.com/vpc/)s. We have been using [VPC-peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) connections to allow our microservices to communicate with shared services. We recently made the switch to [AWS Transit Gateways (TGW)](https://aws.amazon.com/transit-gateway/), which has reduced the maintenance overhead, complexity, and increased the robustness of our cloud infrastructure.

## Managing Multiple Environments

All our environments (test, qa, and production) are orchestrated by [Terraform](https://www.terraform.io/). The environments are spread across multiple AWS accounts, which are all part of the same overall organization. We maintain [VPC](https://aws.amazon.com/vpc/) level isolation between environments. In our test environments, both the databases and microservices reside within the same VPC; in qa and prod environment, our databases and microservices are in seperate VPCs.

Splitting the different services and environments into separate VPCs gives us good isolation between the environments, it also gives us the ability to create and destroy environments on-demand. However, some services are shared across all environments, and some method of access between the VPCs needs to be established. From time to time, we also need to perform admin tasks securely on databases or investigate why an EC2 instance is behaving abnormally. In such cases, one might want to login to servers in a specific VPC, so we need to maintain easy access to all of the active VPCs in the overall architecture while keeping the number of possible attack vectors low.

Until recently, this could have been solved by:

- deploying everything into a public subnet
- using bastion hosts in each environment / VPC
- VPC peering and Transit VPCs (hub and spoke, full mesh)

Our earlier approach to resolving this issue was to use [VPC-peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) in each environment to establish connections between the stateless microservices and stateful databases. This VPC-peering setup became quite labour-intensive to maintain, and we recently switched to a much more manageable network architecture: AWS Transit Gateways. Let's first see what the methods listed above are and what their downsides are before discussing Transit Gateways.

### Deploying Everything in the Public Subnet

One option to resolve the access issue is to just run everything on the public internet. When everything is running in a public subnet, the simplest way to connect to EC2 instances is over SSH. For AWS hosted databases, one can [connect to them over SSL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html). If the databases are running inside EC2, one could use the EC2 host as a jump server to connect to the databases.

While simple, the major drawback with this approach is that it leaves all services exposed to the public internet, and as such has a huge attack surface. Server hardening must be run regularly on all instances, significantly increasing the maintenance overhead. Accounting for the fact that all services are replicated into multiple environments, this approach quickly becomes completely unmanageable, at best slowing down the speed of development and at worst leaving critical customer information exposed.

### Using bastion hosts in each environment

Another commonly used approach is to use [bastion hosts](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html). Bastion servers reduce the attack surface to just the number of bastion hosts and are thus more secure compared to the previous approach. However, the bastion servers need to be deployed in multiple availability zones and need regular maintenance, again significantly increasing the maintenance overhead of the overall system. Each bastion host is typically exposed to the internet, also increasing the attack surface.

### VPC Peering and Transit VPCs

Transit VPCs are yet another approach that helps in managing lots of independent VPCs and in reducing the attack surface on the services running in those VPCs. There are two broad architectures with transit VPCs: Hub and Spoke and fully meshed. The choice of which to use depends on the use case.

#### Hub and Spoke Architecture

If managing the test environments is the only concern, a Hub and Spoke model makes the most sense. In this approach, a single VPC, called the transit VPC, establishes a point-to-point connection to all the other VPCs. A user logs in to this transit VPC and could ***potentially*** have access to all the environments. This transit VPC could run a bastion host or a vpn server which users connect to.

This architecture greatly reduces the attack surface, which also doesn't increase with the number of VPCs. In this architecture, the transit VPC is the hub, and each VPC peering that it establishes becomes a spoke of the architecture.

<center>
<figure>
  <img style="width: 42.5%; height: 42.5%" src="/images/2019_07_15/hub_and_spoke.png">
  <figcaption><b>Hub and spoke transit VPC</b> <br>(Image taken from https://aws.amazon.com/answers/networking/aws-single-region-multi-vpc-connectivity/)</figcaption>
</figure>
</center>

#### Fully-Meshed Architecture

Predicting the future requirements of a dynamic cloud architecture is hard. As the architecture evolves, all environments may at some point need access to some shared services that are non-sensical to replicate for each environment. In our case, there are a bunch of third-party integrations that are required by all environments. As VPC peerings are not transitive in nature, a new VPC peering connection is needed for every other VPC that is connected to. This fully-meshed architecture also reduces the attack radius to a great extent but gets increasingly complex as the number of environments increase.

<center>
<figure>
  <img style="width: 42.5%; height: 42.5%" src="/images/2019_07_15/full_mesh.png">
  <figcaption><b>Fully meshed transit VPC</b> <br>(Image taken from https://aws.amazon.com/answers/networking/aws-single-region-multi-vpc-connectivity/)</figcaption>
</figure>
</center>

While much more robust than bastion hosts, VPC peerings come with their own downsides, documented [here](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html#vpc-peering-limitations) and [here](https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html).

### Transit Gateways

An ideal setup would have a minimal attack surface and be easy to manage. The complexity of the setup should not increase as the number of environments increases. Luckily, AWS  [announced](https://aws.amazon.com/blogs/aws/new-use-an-aws-transit-gateway-to-simplify-your-network-architecture/) just that last year!  A new VPC feature called [Transit Gateways (TGW)](https://aws.amazon.com/transit-gateway/).

In this architecture, all VPCs connect to a central *"router"* called a Transit Gateway. When all VPCs connect to the transit gateway, they could potentially access each other if their routing rules and security groups allow it. Furthermore, transit gateways can be shared across multiple accounts within the same organization, different organization, or account. So it really doesn't matter which account or accounts the VPCs are in.

Resources from one AWS account can be shared across other accounts through a new AWS service called [Resource Access Manager (RAM)](https://aws.amazon.com/ram/).

In our case, we have the transit gateway in our master account, and it is shared with our other AWS accounts for test and production environments. Once shared, each sub-account can see the shared resource(s). All they have to do next is to attach to this transit gateway and adjust the routing rules accordingly.

One very important thing in the VPC peering architecture or transit gateway architecture is that all VPCs should have unique CIDRs.

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

Once the transit gateway is created, it can be shared via RAM within your AWS organization.

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

Once the core infra has been established, VPCs can now attach to the transit gateway. Let's go ahead and create a new VPC called `infra`.

`infra` is our transit VPC where our Engineers connect to via VPN.

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

The above VPC can then be attached to our core TGW. Below is a full-blown snippet on how one can connect the `infra` VPC to the `core-tgw`.

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

Our previous architecture with VPC peerings looked approximately as shown below:

<center>
<figure>
  <img style="width: 100.0%; height: 100.0%" src="/images/2019_07_15/vpc_peering_old_setup.png">
  <figcaption><b>Cloud architecture at Comtravo with vpc peerings</b> <br></figcaption>
</figure>
</center>

We migrated completely to transit gateways, and our architecture has simplified immensely and looks approximately as below.

<center>
<figure>
  <img style="width: 100.0%; height: 100.0%" src="/images/2019_07_15/current_setup.png">
  <figcaption><b>Current VPC architecture at Comtravo</b> <br></figcaption>
</figure>
</center>

In the next blog post, we will look into how one could centrally manage access to the cloud with transit gateways and client-to-site VPN endpoints.

