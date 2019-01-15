# aws-serverless-monitoring

[![CircleCI](https://circleci.com/gh/giusedroid/aws-vpc-blueprint.svg?style=svg)](https://circleci.com/gh/giusedroid/aws-vpc-blueprint)

Aiming at building a serverless monitoring stack on AWS. Stay tuned.

## Imports

This package depends of your AWS account to have the following resources available and their relative Export Values.

| Export Name                       | Resource                                                     |
|--------------------------------   |-------------------------------------------------------    |
| ${Environment}-vpc                | VPC Id                                                    |
| ${Environment}-public-subnets     | Comma (,) separated list of public subnet ids             |
| ${Environment}-private-subnets    | Comma (,) separated list of private subnet ids            |
| ${Environment}-data-subnets       | Comma (,) separated list of data (private) subnet ids     |

Can't be bothered? Feel free to grab this [VPC](https://github.com/giusedroid/aws-vpc-blueprint)

## Exports

