// Configuration AutoGenerated by CloudQuery CLI
cloudquery {
  plugin_directory = "./cq/providers"
  policy_directory = "./cq/policies"

  provider "aws" {
    version = "latest"
  }

  connection {
    dsn = "${DSN}"
  }
}

// All Provider Configurations

provider "aws" {
  configuration {
    // Optional. if you want to assume role to multiple account and fetch data from them
    //accounts "<YOUR ACCOUNT ID>" {
    // Optional. Role ARN we want to assume when accessing this account
    // role_arn = <YOUR_ROLE_ARN>
    // Optional. Account ID we want to assume when accessing this account - override the block label
    // account_id = <YOUR ACCOUNT ID>
    // }
    // Optional. by default assumes all regions
    // regions = ["us-east-1", "us-west-2"]
    // Optional. Enable AWS SDK debug logging.
    aws_debug = false
    // The maximum number of times that a request will be retried for failures. Defaults to 5 retry attempts.
    // max_retries = 5
    // The maximum back off delay between attempts. The backoff delays exponentially with a jitter based on the number of attempts. Defaults to 60 seconds.
    // max_backoff = 30
  }

  // list of resources to fetch
  resources = [
    "*"
  ]
}
