module "network" {
  source = "./modules/networking"
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  dmz_subnet_cidr      = "10.0.2.0/24"
  servers_subnet_cidr  = "10.0.3.0/24"
  db_subnet_cidr = "10.0.4.0/24"
}

module "eks" {
  source = "./modules/eks"
  
  vpc_id            = module.network.vpc_id
  servers_subnet_id = module.network.servers_subnet_id
  
  depends_on = [module.network]
}

module "elk" {
  source = "./modules/elk"
  
  depends_on = [module.eks]
}