package test

import (
	"testing"
	// "fmt"
	"time"
    "math/rand"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/stretchr/testify/assert"
)

var terraformDirectory = "../examples"
var region             = "us-east-1"
var account            = ""
var vpc_id             = "vpc-49fb682f"
var subnets_id         = []string{"subnet-8d79a2eb", "subnet-938b23db", "subnet-ecfc19b6"}

func Test(t *testing.T) {
	rand.Seed(time.Now().UnixNano())

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDirectory,

		Vars: map[string]interface{}{
			"aws_region": region,
			"cluster_name": "Test_EKS_name_" + randSeq(10),
			"vpc_id": vpc_id,
			"subnets_id": subnets_id,
			"ami_id": "ami-01e08d22b9439c15a",
  			"instance_type": "m4.large",
  			"asg_max_size": "10",
  			"spot_price": "0.05",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.Init(t, terraformOptions)
	terraform.Apply(t, terraformOptions)
	account = terraform.Output(t, terraformOptions, "account_id")
}

func randSeq(n int) string {
	letters := []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    b := make([]rune, n)
    for i := range b {
        b[i] = letters[rand.Intn(len(letters))]
    }
    return string(b)
}
