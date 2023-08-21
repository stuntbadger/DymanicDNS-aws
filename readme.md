# Dynamic DNS in AWS 

Hello with the high costs of running Dynamic DNS in hosted services like noip.com I decided to move away from custom services and set up my own at a fraction of the cost by running my services in AWS


# 

Requirementss Domain in AWS and one subdomain e.g. www.

This process requires the following packages installed 
dig
awscli 
curl 



## Creating the user to in IAM with Access key and Secret Key 

1. create the user 

        aws iam create-user --user-name dns-updater

2. Attach the `AmazonRoute53FullAccess` managed policy to the user

        aws iam attach-user-policy --user-name dns-updater \
       --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess
3. This policy grants full access to Route 53, Amazon's DNS service.

        aws iam create-access-key --user-name dns-updater

This will output the `AccessKeyId` and `SecretAccessKey` for the user. this is needed to install these values in the main updateroute53.sh script ( line 6 and 7) 


## ZoneID
To retive your HostedZoneID you and see this by running the following command line or obtain this in the GUI under hosted zone in route53 

        aws route53 list-hosted-zones

now add this value to line 5 in the updateroute53.sh script

## Hostname 
This is the name of your A record you are looking to update in this update I am updating www.example.com 
(line 4  in the updateroute53.sh script) 


## Cron 
you can run this as any user in this exmple I am running this at a user account rather than root 
first make this executable 
        chmod 774 updateroute53.sh 

        crontab -e 
        
        */5 * * * * /home/user/updateroute53.sh > /dev/null 2>&1

## Costing 
Doamin price $9 -$13 for the Registration per year
Route53 Hosted Zone costs
$0.50 per hosted zone / month for the first 25 hosted zones
$0.10 per hosted zone / month for additional hosted zones
### Queries
The following query prices are prorated; for example, a hosted zone with 100,000 standard queries / month would be charged $0.04 and a hosted zone with 100,000 Latency-Based Routing queries / month would be charged $0.06.

### Standard Queries
$0.40 per million queries – first 1 Billion queries / month

$0.20 per million queries – over 1 Billion queries / month
