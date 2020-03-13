# GCP-TFE-Cluster

This is a combination and modification of the 2 repos from Hashi and a custome module for cert creation to build the TFE cluster on GCP
repo 1: private-terraform-enterprise 
repo 2: terraform-google-terraform-enterprise 
seperare module: cent_gen

## to start deployment from a new project in GCP
Start with repo 1
If you have an empty test project, you can create the required infrastructure resources with an [example bootstrap Terraform module][bootstrap]. This module only requires the following:

* Access to the project via a JSON authentication file.
* A DNS zone.

The module will create the VPC, the subnet, and the required firewalls. It will also get a public IP, create a DNS entry for it, and create a managed SSL certificate for the domain and an SSL policy for the certificate.

## if a custom self managed certs is required, follow 
1. run terraform code in cert_gen to create self sign cert
2. after obtaining the cert, key and root_ca_cert, upload those cert to GCP console as self managed cert
    https://console.cloud.google.com/net-services/loadbalancing/advanced/sslCertificates/list 
3. pass down the cert name in next steps

## Run the terraform workflow from terraform-google-terraform-enterprise/examples/root-example 

### Architecture
![basic diagram](https://github.com/hashicorp/terraform-google-terraform-enterprise/blob/master/assets/gcp_diagram.jpg?raw=true)
_example architecture_

Create the approriate var files or fill in the variables in main.tf 
4. Initialize Terraform and run a plan. If you are running Terraform from the CLI, you can do this by navigating to the configuration's directory and running:

    ```
    $ terraform init
    $ terraform plan -out planfile
    ```
5. If the plan runs without errors and looks correct, apply it:

    ```
    $ terraform apply planfile
    ```

    -> **Note:** The apply can take several minutes.
6. Once the apply has finished, Terraform will display any root-level outputs you configured. For example:

    ```text
    Apply complete! Resources: 37 added, 0 changed, 0 destroyed.

    Outputs:

    tfe_cluster = {
      application_endpoint = https://tfe.example.com
      application_health_check = https://tfe.example.com/_health_check
      installer_dashboard_password = hideously-stable-baboon
      installer_dashboard_url = https://12.34.56.78:8800
      primary_public_ip = 23.45.67.89
    }
    ```

    At this point, the infrastructure is finished deploying, but the application is not. It can take up to 30 minutes before the website becomes available.

    The installer dashboard should become available first, and is accessible at the URL specified in the `installer_dashboard_url` output. This will be the first primary server; currently, the dashboard is not behind the load balancer. After other primary servers come up, you can access the dashboard on any of them.
7. Open the installer dashboard in your web browser, and log in with the password specified in the `installer_dashboard_password` output. Follow the instructions at [Terraform Enterprise Configuration](../install/config.html) to finish setting up the application.

After the application is fully deployed, you can adjust the cluster's size by changing the module's inputs and re-applying the Terraform configuration.


## Explanation of variables

Please see the [hashicorp/terraform-enterprise/google registry page][inputs] for a complete list of input variables. The following variables have some additional notes:

* `certificate` - The GCP link to the certificate. If you'd like to use a certificate from another source, you can specify the filename in this variable, and then comment out lines 13 and 14 in the file `gcp/modules/lb/forwarding_rule.tf` and uncomment line 16.
* `ssl_policy` - The GCP SSL policy to use. If you are providing a certificate file, comment out this section in the `variables.tf` file and the `gcp/modules/lb/forwarding_rule.tf` file.
* `postgresql_password` - This is the password for connecting to Postgres, in base64. To base64 encode your password, run `base64 <<< databasepassword` on the command line. Specify that output as the variable's value.
* `airgap_package_url` - Please download the airgap package you'll use and store it in an artifact repository or some other web-accessible location. Do not use the direct download URL from the vendor site - that URL is time-limited!


