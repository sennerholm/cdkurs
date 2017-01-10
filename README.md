# cdkurs
Raw materials for CD kurs jan 2017

# Vart är man idag
* Hur mycket molntjänster har man använt?
* Docker
* Swarm/Kubernetes/Rancher
* Infrastructure as code? Terraform?

# Docker

Vad är en Container?
Vad är den bra för?

Starta en med våra tools i och exponera det utcheckade gitrepot.
(docker run -it -v $PWD:/data )

# Start with Terraform

*** Terraform ***
Terraform from Hashicorp (same suite as Vagrant/Packer etc)
Download and install from: https://www.terraform.io/

*** Deploy stuff to AWS ***
Need credentials. Place a fil into terraform/aws/credentials (see sample)

terraform plan
terraform apply

Logga in på ip till rancher server

Kopiera token till variables
öka antalet test till 3 (och byta till infrastructure)

plan/apply

Se att alla hostar kommer upp och infrastructure bitarna också

Prova att deploya en wordpress
Se att den går att nå , för vi har ingen ELB på plats (TODO)

Lägga till en catalog
Clona mitt repo
Lägg in (som https inte git url)

Rancher compose
 - Go server + agent (TODO med en image som har pluginen vi vill ha installerad och konf)

Ställa in en pipeline (mot clonat repo, ändra en rad i confen)

Repository att lagra på (registrera på hub.docker.com)
(Även visa hur jag automat byggt en del av det som vi använder)

Prova att skapa en tjänst på den!

Skapa API nyckel
 - Skapa test och prod (via script)
# Stoppa in credentials mot test stacken (som skapas)
# Deploya den till vår test stack

Sätta upp en autolargeuat och prodstack
Sätta upp en prod stack

Promota dit

Visa rullande upgrade

# Todo
Go server med färdig konf i.
Docker med tools. 
 - rancher cli https://github.com/rancher/cli/releases
 - terraform 
 - Att köra scripten i för att sätta up ny stack
 - jq
Cachande artifactory/registry på olika delar (https://www.jfrog.com/confluence/display/RTF/Running+with+Docker#RunningwithDocker-PullingtheArtifactoryDockerImage)
Test instans
Extension, sätta upp ett kubernetes kluster
Go server med https://github.com/tomzo/gocd-yaml-config-plugin/releases färdig i