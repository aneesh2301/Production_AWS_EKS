This is an EKS production grade project. It's in developing stage. 

Step 1: Configured the remote-backend using S3 and DynamoDB with all the security measures.

Step 2: I have utilised AWS Terraform modules of VPC, EKS to setup the Infrastructure. For now, I am creating the Infrastructure in environment dev. 

* The VPC module is going to create the following in the 2 AZ's.

> 2 Public Subnets 
> 2 Private Subnets 
> 1 NAT-Gateway
> 1 Internet-Gateway
> Public route table between IG and Public Subnet 
> Private route table between NAT-Gateway and Private Subnet

* I have utilised EKS module with Managed Node Groups.

> Nodes will be deployed in Private Subnets
> Enabled IRSA (IAM roles for Service Accounts for fine-grained least privilege)
> Enabled cluster endpoint public access (OK for dev env, not recommended for prod env)
> Creates OIDC (Open ID connecter) provider and outputs the URL
> Access can be provided to IAM user's using access entries
> Enabled logging for all Control-plane components
> Required cluster Addons (CoreDNS, kube-proxy, vpc-cni)

Step 3: Deploying kubernetes components via Terraform Helm provider.....